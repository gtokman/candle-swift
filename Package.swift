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
        .package(url: "https://github.com/candlefinance/swift-security.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "CandlePublic",
            dependencies: [
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
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
