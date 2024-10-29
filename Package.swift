// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Function",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "Function",
            targets: ["FunctionSwift"]
        ),
        .plugin(
            name: "FunctionEmbed",
            targets: ["Embed Predictors"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/fxnai/XcodeProj.git", revision: "6bb836a")
    ],
    targets: [
        .target(
            name: "FunctionSwift",
            dependencies: ["Function"],
            path: "Sources/Function",
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .binaryTarget(
            name: "Function",
            url: "https://cdn.fxn.ai/fxnc/0.0.30/Function.xcframework.zip",
            checksum: "80e92b9997e60651ac9ace5705e5ecd2d65c04f25a71f5dc82f4accd2df673fd"
        ),
        .testTarget(
            name: "FunctionTests",
            dependencies: ["FunctionSwift"]
        ),
        .executableTarget(
            name: "FunctionEmbedder",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "XcodeProj", package: "XcodeProj")
            ],
            path: "Sources/Embed"
        ),
        .plugin(
            name: "Embed Predictors",
            capability: .command(
                intent: .custom(
                    verb: "fxn",
                    description: "Function will embed predictors into your app."
                ),
                permissions: [
                    .allowNetworkConnections(
                        scope: .all(ports: [80, 443]),
                        reason: "Allow Function to download and embed predictors into your app."
                    ),
                    .writeToPackageDirectory(reason: "Allow Function to embed predictors into your app.")
                ]
            ),
            dependencies: ["FunctionEmbedder"],
            path: "Plugins/Embed"
        )
    ]
)
