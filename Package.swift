// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "alpaca-market-stream-server",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "alpaca-market-stream-server",
            targets: ["alpaca-market-stream-server"]
        ),
        .library(name: "TradingEngine", targets: ["TradingEngine"]),
        .library(name: "AlpacaTradingAPI", targets: ["AlpacaTradingAPI"]),
        .library(name: "NUTool", targets: ["NUTool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.105.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.4"),
    ],
    targets: [
        .executableTarget(
            name: "alpaca-market-stream-server",
            dependencies: [.target(name: "TradingEngine"),
                           .target(name: "AlpacaTradingAPI"),
                           .product(name: "Vapor", package: "vapor"),
                           .product(name: "Logging", package: "swift-log"),
                          ]
        ),
        .target(name: "AlpacaTradingAPI",
                dependencies: [
                    .target(name: "NUTool"),
                    .product(name: "Logging", package: "swift-log"),
                ]
        ),
        .target(
            name: "TradingEngine",
            dependencies: [
                .target(name: "NUTool"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .target(
            name: "NUTool"
        ),
        .testTarget(
            name: "alpaca-market-stream-serverTests",
            dependencies: [
                "alpaca-market-stream-server",
            ]
        ),
    ]
)

