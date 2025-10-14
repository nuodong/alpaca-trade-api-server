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
            name: "TradeServer",
            targets: ["TradeServer"]
        ),
        .library(name: "AlpacaMarketDataHub", targets: ["AlpacaMarketDataHub"]),
        .library(name: "AlpacaTradingAPI", targets: ["AlpacaTradingAPI"]),
        .library(name: "TradingEngine", targets: ["TradingEngine"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.105.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.4"),
    ],
    targets: [
        .target(
            name: "AlpacaMarketDataHub",
            dependencies: [
                           .product(name: "Vapor", package: "vapor"),
                           .product(name: "Logging", package: "swift-log"),
                          ]
        ),
        
        .target(name: "AlpacaTradingAPI",
                dependencies: [
                    .product(name: "Logging", package: "swift-log"),
                ]
        ),
        .target(
            name: "TradingEngine",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .executableTarget(
            name: "TradeServer",
            dependencies: [
                .target(name: "AlpacaMarketDataHub"),
                .target(name: "TradingEngine"),
                .target(name: "AlpacaTradingAPI"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "AlpacaMarketDataHubTests",
            dependencies: [
                "AlpacaMarketDataHub",
            ]
        ),
    ]
)

