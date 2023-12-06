// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TextEmbossHTTP",
    products: [
        .library(
            name: "TextEmbossHTTP",
            targets: ["TextEmbossHTTP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/sfomuseum/swift-text-emboss", from: "0.0.3"),
        // .package(name: "swift-text-emboss", path: "/usr/local/sfomuseum/swift-text-emboss"),
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/sfomuseum/swift-coregraphics-image.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TextEmbossHTTP",
                dependencies: [
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    .product(name: "TextEmboss", package: "swift-text-emboss"),
                    .product(name: "Swifter", package: "swifter"),
                    .product(name: "Logging", package: "swift-log"),
                    .product(name:"CoreGraphicsImage", package: "swift-coregraphics-image")
            ]
        ),
        .executableTarget(
            name: "text-emboss-server",
            dependencies: [
                "TextEmbossHTTP",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "TextEmboss", package: "swift-text-emboss"),
                .product(name: "Swifter", package: "swifter"),
                .product(name: "Logging", package: "swift-log"),
                .product(name:"CoreGraphicsImage", package: "swift-coregraphics-image")
            ],
            path: "Scripts"
        )
    ]
)
