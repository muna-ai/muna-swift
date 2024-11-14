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
            targets: ["Embed Predictors", "Bootstrap Project"]
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
            url: "https://cdn.fxn.ai/fxnc/0.0.31/Function.xcframework.zip",
            checksum: "4b0a13719c5849471311672628c5f08c67a93fa070b03c4e22813e7158a70891"
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
            name: "Bootstrap Project",
            capability: .command(
                intent: .custom(
                    verb: "fxn-init",
                    description: "Initialize Function in your iOS app target."
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Allow Function write the Function configuration template.")
                ]
            ),
            path: "Plugins/Bootstrap"
        ),
        .plugin(
            name: "Embed Predictors",
            capability: .command(
                intent: .custom(
                    verb: "fxn-embed",
                    description: "Embed predictors into your app bundle."
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
