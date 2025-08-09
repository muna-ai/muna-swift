// swift-tools-version: 5.9

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
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Muna",
            dependencies: ["Function"],
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
        )
    ]
)
