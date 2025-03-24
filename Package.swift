// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Candle",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Candle",
            targets: ["CandlePublic"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-urlsession", exact: "1.0.2"),
        .package(url: "https://github.com/apple/swift-nio.git", exact: "2.81.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", exact: "2.29.3"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", exact: "1.23.1"),
        .package(url: "https://github.com/candlefinance/swift-security.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "CandlePublic",
            dependencies: [
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "NIOTransportServices", package: "swift-nio-transport-services"),
                .product(name: "SwiftSecurity", package: "swift-security"),
                "Candle",
            ]
        ),
        .binaryTarget(
            name: "Candle",
            path: "./Candle.xcframework"
        ),
    ]
)
