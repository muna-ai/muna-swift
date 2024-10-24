//
//  Embed.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/24/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation
import PackagePlugin
import XcodeProjectPlugin

@main
struct FunctionEmbed: CommandPlugin, XcodeCommandPlugin {
    
    struct Configuration : Codable {
        public let tags: [String]
        public let envPath: String?
        public var apiUrl: String?
        public var accessKey: String?
    }
    
    struct PredictionResource : Codable {
        public let type: String
        public let url: String
        public let name: String?
    }
    
    struct Prediction : Codable {
        public let id: String
        public let tag: String
        public let resources: [PredictionResource]
        public let created: String
    }

    func performCommand (context: PluginContext, arguments: [String]) throws { }
    
    func performCommand (context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        // Check valid target
        let targetName = arguments[1]
        guard let target = context.xcodeProject.targets.first(where: { $0.displayName == targetName }) else {
            return
        }
        // Check that a directory corresponding to the target exists
        let fileManager = FileManager.default;
        let projectPath = URL(fileURLWithPath: context.xcodeProject.directory.string)
        let targetPath = projectPath.appending(path: targetName, directoryHint: .isDirectory)
        if !fileManager.fileExists(atPath: targetPath.path) {
            return
        }
        // Create predictor frameworks directory
        let frameworksPath = targetPath.appending(path: "Function", directoryHint: .isDirectory)
        if fileManager.fileExists(atPath: frameworksPath.path) {
            try fileManager.removeItem(at: frameworksPath)
        }
        try fileManager.createDirectory(at: frameworksPath, withIntermediateDirectories: true)
        // Parse configuration
        let configPath = targetPath.appending(path: "fxn.config.swift")
        var config = try parseConfiguration(path: configPath.path)
        // Parse env
        let defaultEnvPath = configPath.deletingLastPathComponent().appending(path: "fxn.xcconfig")
        let envPath = config.envPath ?? defaultEnvPath.path
        let env = try parseEnv(at: envPath)
        config.accessKey = env["FXN_ACCESS_KEY"] ?? ""
        config.apiUrl = env["FXN_API_URL"] ?? "https://api.fxn.ai/v1"
        // Build payload
        let payload: [String: Any] = [
            "tag": config.tags[0],
            "clientId": "ios-arm64"
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
        let url = URL(string: "\(config.apiUrl!)/predictions")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.accessKey!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        // Request
        var prediction: Prediction?
        var predictionError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                semaphore.signal()
            }
            if let error = error {
                predictionError = FunctionError.networkError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                predictionError = FunctionError.invalidResponse
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: [])
            let payload = jsonObject as? [String: Any]
            if httpResponse.statusCode != 200 {
                let errors = payload?["errors"] as? [[String: Any]]
                if let message = errors?.first?["message"] as? String {
                    predictionError = FunctionError.serverError(message)
                } else {
                    predictionError = FunctionError.invalidStatusCode(httpResponse.statusCode)
                }
                return
            }
            let decoder = JSONDecoder()
            prediction = try? decoder.decode(Prediction.self, from: data!)
        }
        task.resume()
        semaphore.wait()
        // Check
        if let error = predictionError {
            throw error
        }
        // Download
        for resource in prediction!.resources {
            if resource.type == "dso" {
                let url = URL(string: resource.url)
                try downloadFramework(from: url!, to: frameworksPath)
            }
        }
        // Update manifest
        
    }
    
    private func parseConfiguration (path: String) throws -> Configuration {
        let prefix = """
        public class Function {

            struct Configuration : Codable {
                
                public let tags: [String]
                
                public init (tags: [String]) {
                    self.tags = tags
                }
            }
        }
        """
        let suffix = """

        import Foundation

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        if let jsonData = try? encoder.encode(config),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        } else {
            fatalError("Failed to encode config to JSON")
        }
        """
        // Create script
        var script = try String(contentsOfFile: path, encoding: .utf8)
        script = script.replacingOccurrences(of: "import FunctionSwift", with: "")
        script = prefix + script + suffix
        let tempDirectory = FileManager.default.temporaryDirectory
        let scriptUrl = tempDirectory.appendingPathComponent("fxn.config.swift")
        try script.write(to: scriptUrl, atomically: true, encoding: .utf8)
        // Execute
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", scriptUrl.path]
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()
        // Check
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "ScriptExecutionError",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: errorOutput]
            )
        }
        // Parse
        let decoder = JSONDecoder()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let config = try decoder.decode(Configuration.self, from: outputData)
        // Return
        return config
    }
    
    private func loadAuth (from path: String) throws -> (accessKey: String, apiUrl: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
        process.arguments = ["-showBuildSettings", "-xcconfig", path, "-json"]
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let json = try? JSONSerialization.jsonObject(with: outputData, options: []) as? [[String: Any]] else {
            throw FunctionError.invalidAuthConfig
        }
        guard let buildSettings = json.first?["buildSettings"] as? [String: Any] else {
            throw FunctionError.invalidAuthConfig
        }
        let accessKey = buildSettings["FXN_ACCESS_KEY"] as? String ?? ""
        let apiUrl = buildSettings["FXN_API_URL"] as? String ?? "https://api.fxn.ai/v1"
        return (accessKey, apiUrl)
    }
    
    private func parseEnv (at path: String) throws -> [String: String] {
        let contents = try String(contentsOfFile: path, encoding: .utf8)
        var config: [String: String] = [:]
        let lines = contents.split(separator: "\n")
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.hasPrefix("//") || trimmedLine.isEmpty {
                continue // Skip comments and empty lines
            }
            let components = trimmedLine.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            if components.count != 2 {
                continue
            }
            let key = components[0]
            var value = components[1]
            value = value.hasPrefix("\"") && value.hasSuffix("\"") ? String(value.dropFirst().dropLast()) : value
            config[key] = value
        }
        return config
    }
    
    private func downloadFramework (from url: URL, to directory: URL) throws {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        let downloadedFilePath = tempDirectory.appendingPathComponent(url.lastPathComponent)
        let data = try Data(contentsOf: url)
        try data.write(to: downloadedFilePath)
        let unzippedDirectory = tempDirectory.appendingPathComponent("unzipped")
        try fileManager.createDirectory(at: unzippedDirectory, withIntermediateDirectories: true, attributes: nil)
        try unzipFile(at: downloadedFilePath, to: unzippedDirectory)
        let unzippedContents = try fileManager.contentsOfDirectory(at: unzippedDirectory, includingPropertiesForKeys: nil, options: [])
        for content in unzippedContents {
            let destination = directory.appendingPathComponent(content.lastPathComponent)
            try fileManager.copyItem(at: content, to: destination)
        }
        try fileManager.removeItem(at: tempDirectory)
    }
    
    private func unzipFile (at zipFilePath: URL, to destinationDirectory: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = [zipFilePath.path, "-d", destinationDirectory.path]
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw FunctionError.downloadError
        }
    }
}

enum FunctionError: Error {
    case networkError(Error)
    case invalidResponse
    case invalidStatusCode(Int)
    case serverError(String)
    case invalidAuthConfig
    case downloadError
}
