/*
*   Muna
*   Copyright © 2025 NatML Inc. All rights reserved.
*/

import ArgumentParser
import Foundation
import PathKit
import XcodeProj

@main
struct Embed: ParsableCommand {

    @Argument(help: "Frameworks to embed.")
    var frameworks: [String] = []

    @Option(name: .long, help: "Path to .xcodeproj.")
    var project: String? = nil

    @Option(name: .long, help: "Target name to patch.")
    var target: String? = nil

    func run() throws {
        let projectPath = Path(project!)
        let projectDirectory = projectPath.parent().string
        let project = try XcodeProj(path: projectPath)
        let pbxproj = project.pbxproj
        guard let target = pbxproj.targets(named: target!).first else {
            fatalError("Target not found")
        }
        let embedFrameworksPhase = findOrCreateEmbedFrameworksPhase(for: target, in: pbxproj)
        removeStaleFrameworks(phase: embedFrameworksPhase, pbxproj: pbxproj)
        let targetGroup = target.fileSystemSynchronizedGroups![0]
        for framework in frameworks {
            let exception = PBXFileSystemSynchronizedGroupBuildPhaseMembershipExceptionSet(
                buildPhase: embedFrameworksPhase,
                membershipExceptions: ["Function/\(framework)"],
                attributesByRelativePath: [
                    "Function/\(framework)": ["RemoveHeadersOnCopy"]
                ]
            )
            pbxproj.add(object: exception)
            targetGroup.exceptions?.append(exception)
        }
        try project.write(path: projectPath)
    }

    func findOrCreateEmbedFrameworksPhase(for target: PBXTarget, in pbxproj: PBXProj) -> PBXCopyFilesBuildPhase {
        if let existingEmbedPhase = target.embedFrameworksBuildPhases().first {
            return existingEmbedPhase
        } else {
            let embedFrameworksPhase = PBXCopyFilesBuildPhase(dstSubfolderSpec: .frameworks)
            pbxproj.add(object: embedFrameworksPhase)
            target.buildPhases.append(embedFrameworksPhase)
            return embedFrameworksPhase
        }
    }
    
    func removeStaleFrameworks(phase: PBXCopyFilesBuildPhase, pbxproj: PBXProj) {
        guard let files = phase.files else { return }
        for file in files {
            guard let fileRef = file.file else {
                continue
            }
            let fileName = fileRef.name ?? fileRef.path!
            if !fileName.hasPrefix("Function_") {
                continue
            }
            phase.files?.removeAll { $0 == file }
            pbxproj.delete(object: fileRef)
            pbxproj.delete(object: file)
        }
    }

    func getRelativePath(from root: String, to path: String) throws -> String {
        guard path.hasPrefix(root) else {
            throw MunaError.fileNotFound
        }
        let rootUrl = URL(fileURLWithPath: root).standardized
        let pathUrl = URL(fileURLWithPath: path).standardized
        let rootComponents = rootUrl.pathComponents
        let pathComponents = pathUrl.pathComponents
        let relativeComponents = Array(pathComponents.dropFirst(rootComponents.count))
        let result = relativeComponents.joined(separator: "/")
        return result
    }
}

enum MunaError : Error {
    case groupNotFound(name: String)
    case fileNotFound
}
