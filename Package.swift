// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Function",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "Function",
            targets: ["FunctionSwift"]
        ),
        .plugin(
            name: "FunctionEmbed",
            targets: ["BuildHandler"]
        ),
    ],
    targets: [
        .target(
            name: "FunctionSwift",
            dependencies: ["Function"],
            path: "Sources/Function"
        ),
        .binaryTarget(
            name: "Function",
            url: "https://cdn.fxn.ai/fxnc/0.0.30/Function.xcframework.zip",
            checksum: "80e92b9997e60651ac9ace5705e5ecd2d65c04f25a71f5dc82f4accd2df673fd"
        ),
        .plugin(
            name: "BuildHandler",
            capability: .buildTool(),
            dependencies: [
                "FunctionEmbedder"
            ]
        ),
        .executableTarget(
            name: "FunctionEmbedder",
            dependencies: [],
            path: "Sources/Build"
        ),
        .testTarget(
            name: "FunctionTests",
            dependencies: ["FunctionSwift"]
        ),
    ]
)
