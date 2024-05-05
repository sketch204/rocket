// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rocket",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Rocket", targets: ["Rocket"]),
        
        .library(
            name: "RocketParsing",
            targets: ["RocketParsing"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Rocket",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        
        .target(
            name: "RocketParsing",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),
        .testTarget(
            name: "RocketParsingTests",
            dependencies: [
                "RocketParsing",
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),
    ]
)
