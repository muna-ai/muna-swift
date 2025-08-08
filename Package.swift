// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Muna",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "Muna",
            targets: ["Muna"]
        ),
        .plugin(
            name: "MunaEmbed",
            targets: ["Embed Predictors", "Bootstrap Project"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "9.5.0")
    ],
    targets: [
        .target(
            name: "Muna",
            dependencies: ["Function"],
            path: "Sources/Muna",
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .binaryTarget(
            name: "Function",
            url: "https://cdn.fxn.ai/fxnc/0.0.36/Function.xcframework.zip",
            checksum: "3e312ccd96637f92f9009aa9c86166bc4096c7839f539b7b07020e855fc0ff4e"
        ),
        .testTarget(
            name: "MunaTests",
            dependencies: ["Muna"]
        ),
        .executableTarget(
            name: "MunaEmbedder",
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
                    verb: "muna-init",
                    description: "Initialize Muna in your iOS app target."
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Allow Muna write the Muna configuration template.")
                ]
            ),
            path: "Plugins/Bootstrap"
        ),
        .plugin(
            name: "Embed Predictors",
            capability: .command(
                intent: .custom(
                    verb: "muna-embed",
                    description: "Embed predictors into your app bundle."
                ),
                permissions: [
                    .allowNetworkConnections(
                        scope: .all(ports: [80, 443]),
                        reason: "Allow Muna to download and embed predictors into your app."
                    ),
                    .writeToPackageDirectory(reason: "Allow Muna to embed predictors into your app.")
                ]
            ),
            dependencies: ["MunaEmbedder"],
            path: "Plugins/Embed"
        )
    ]
)
