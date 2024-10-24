// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Function",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Function",
            targets: ["FunctionSwift"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
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
        .testTarget(
            name: "FunctionTests",
            dependencies: ["FunctionSwift"]
        ),
    ]
)
