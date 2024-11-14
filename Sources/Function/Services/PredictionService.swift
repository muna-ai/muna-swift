//
//  PredictionService.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import CoreVideo
import Foundation
import Function
import Metal

public class PredictionService {

    private let client: FunctionClient
    private var cache: [String: CPredictor]
    private static let predictionCache: [String: Prediction] = {
        guard let url = Bundle.main.url(forResource: "fxn", withExtension: "resolved") else {
            return [:]
        }
        guard let data = try? Data(contentsOf: url) else {
            return [:]
        }
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        decoder.dateDecodingStrategy = .formatted(DateFormatter.utcFormatter)
        guard let configuration = try? decoder.decode(ResolvedConfiguration.self, from: data) else {
            return [:]
        }
        let cache = Dictionary(uniqueKeysWithValues: configuration.predictions.map { ($0.tag, $0) })
        return cache
    }()

    internal init (client: FunctionClient) {
        self.client = client
        self.cache = [:]
    }

    public func ready (tag: String) -> Bool {
        return cache.keys.contains(tag)
    }

    public func create (
        tag: String,
        inputs: [String: Any?]? = nil,
        acceleration: Acceleration = .auto,
        device: MTLDevice? = nil,
        clientId: String? = nil,
        configurationId: String? = nil
    ) async throws -> Prediction {
        guard let inputs = inputs else {
            return try await createRawPrediction(
                tag: tag,
                clientId: clientId,
                configurationId: configurationId
            )
        }
        let predictor = try await getPredictor(
            tag: tag,
            acceleration: acceleration,
            device: device,
            clientId: clientId,
            configurationId: configurationId
        )
        let inputMap = try toValueMap(inputs: inputs)
        defer { inputMap.dispose() }
        let prediction = try predictor.createPrediction(inputs: inputMap)
        defer { prediction.dispose() }
        return try toPrediction(tag: tag, prediction: prediction)
    }

    public func stream (
        tag: String,
        inputs: [String: Any],
        acceleration: Acceleration = .auto,
        device: MTLDevice? = nil
    ) async throws -> AsyncThrowingStream<Prediction, Error> {
        let predictor = try await getPredictor(
            tag: tag,
            acceleration: acceleration,
            device: device
        )
        let inputMap = try toValueMap(inputs: inputs)
        defer { inputMap.dispose() }
        let stream = try predictor.streamPrediction(inputs: inputMap)
        return AsyncThrowingStream { continuation in
            defer { stream.dispose() }
            do {
                while let prediction = try stream.readNext() {
                    defer { prediction.dispose() }
                    let result = try toPrediction(tag: tag, prediction: prediction)
                    continuation.yield(result)
                }
            } catch {
                continuation.finish(throwing: error)
                return
            }
            continuation.finish()
        }
    }

    public func delete (tag: String) async throws -> Bool {
        guard let predictor = cache[tag] else {
            return false
        }
        cache.removeValue(forKey: tag)
        predictor.dispose()
        return true
    }

    private func createRawPrediction (
        tag: String,
        clientId: String? = nil,
        configurationId: String? = nil,
        predictionId: String? = nil
    ) async throws -> Prediction {
        return try await client.request(
            method: "POST",
            path: "/predictions",
            payload: [
                "tag": tag,
                "clientId": clientId ?? Configuration.clientId,
                "configurationId": configurationId ?? Configuration.uniqueId,
                "predictionId": predictionId
            ]
        )!
    }

    private func getPredictor (
        tag: String,
        acceleration: Acceleration = .auto,
        device: MTLDevice? = nil,
        clientId: String? = nil,
        configurationId: String? = nil
    ) async throws -> CPredictor {
        if let predictor = cache[tag] {
            return predictor
        }
        let prediction = try await createRawPrediction(
            tag: tag,
            clientId: clientId,
            configurationId: configurationId,
            predictionId: PredictionService.predictionCache[tag]?.id
        )
        let configuration = Configuration()
        defer { configuration.dispose() }
        configuration.tag = prediction.tag
        configuration.token = prediction.configuration
        configuration.acceleration = acceleration
        configuration.device = device
        for resource in prediction.resources! {
            let path = try await downloadResource(resource: resource)
            try configuration.addResource(type: resource.type, path: path)
        }
        let predictor = try CPredictor(configuration: configuration)
        cache[tag] = predictor
        return predictor
    }

    private func downloadResource (resource: PredictionResource) async throws -> String {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cacheDir = documentsDir.appendingPathComponent("fxn").path
        let resourcePath = try getResourcePath(resource: resource, cacheDir: cacheDir)
        if FileManager.default.fileExists(atPath: resourcePath) {
            return resourcePath
        }
        try FileManager.default.createDirectory(
            atPath: (resourcePath as NSString).deletingLastPathComponent,
            withIntermediateDirectories: true,
            attributes: nil
        )
        guard let url = URL(string: resource.url) else {
            throw URLError(.badURL)
        }
        let (temporaryURL, response) = try await URLSession.shared.download(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let resourceUrl = URL(fileURLWithPath: resourcePath)
        try FileManager.default.moveItem(at: temporaryURL, to: resourceUrl)
        return resourcePath
    }

    private func getResourcePath (resource: PredictionResource, cacheDir: String) throws -> String {
        guard let url = URL(string: resource.url) else {
            throw FunctionError.invalidArgument(message: "Resource URL is invalid")
        }
        let stem = url.lastPathComponent
        if let name = resource.name {
            return (cacheDir as NSString).appendingPathComponent("\(stem)/\(name)")
        } else {
            return (cacheDir as NSString).appendingPathComponent(stem)
        }
    }

    private func toValue (input: Any?) throws -> Value {
        switch (input) {
        case nil:
            return try Value.createNull()
        case let scalar as Float16:
            let tensor = Tensor(data: [scalar], shape: [])
            return try Value.createArray(data: tensor, flags: .copyData)
        case let scalar as Float:
            let tensor = Tensor(data: [scalar], shape: [])
            return try Value.createArray(data: tensor, flags: .copyData)
        case let scalar as Double:
            let tensor = Tensor(data: [scalar], shape: [])
            return try Value.createArray(data: tensor, flags: .copyData)
        case let scalar as Int:
            let tensor = Tensor(data: [Int32(scalar)], shape: [])
            return try Value.createArray(data: tensor, flags: .copyData)
        case let scalar as Bool:
            let tensor = Tensor(data: [scalar], shape: [])
            return try Value.createArray(data: tensor, flags: .copyData)
        case let array as [Float16]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try Value.createArray(data: tensor)
        case let array as [Float]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try Value.createArray(data: tensor)
        case let array as [Double]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try Value.createArray(data: tensor)
        case let array as [Int]:
            let tensor = Tensor(data: array.map{ Int32($0) }, shape: [array.count])
            return try Value.createArray(data: tensor, flags: .copyData)
        case let array as [Bool]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<Float16>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<Float>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<Double>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<Int8>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<Int16>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<Int32>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<Int64>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<UInt8>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<UInt16>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<UInt32>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<UInt64>:
            return try Value.createArray(data: tensor)
        case let tensor as Tensor<Bool>:
            return try Value.createArray(data: tensor)
        case let string as String:
            return try Value.createString(data: string)
        case let list as [Any]:
            return try Value.createList(data: list)
        case let dict as [String: Any]:
            return try Value.createDict(data: dict)
        case let image as CVPixelBuffer:
            return try Value.createImage(pixelBuffer: image)
        case let data as Data:
            return try Value.createBinary(buffer: data)
        default:
            throw FunctionError.invalidArgument(message: "Object cannot be converted to Function value because it has an unsupported type: \(type(of: input))")
        }
    }

    private func toValueMap (inputs: [String: Any?]) throws -> ValueMap {
        let map = try ValueMap()
        for (key, value) in inputs {
            map[key] = try toValue(input: value)
        }
        return map
    }

    private func toPrediction (tag: String, prediction: CPrediction) throws -> Prediction {
        var result = Prediction(id: try prediction.id, tag: tag, created: Date())
        result.results = try {
            if let outputMap = try prediction.results {
                return try (0..<outputMap.count)
                    .map { try outputMap.key(at: $0) }
                    .map { outputMap[$0] }
                    .map { try $0?.toObject() }
            } else {
                return nil
            }
        }()
        result.latency = try prediction.latency
        result.error = try prediction.error
        result.logs = try prediction.logs
        return result
    }

    private struct ResolvedConfiguration : Codable {
        public let predictions: [Prediction]
    }
}
