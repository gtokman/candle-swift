// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Candle",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Candle",
            targets: ["Candle"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-runtime", exact: "1.7.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", exact: "1.0.2"),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", exact: "24.0.0"),
    ],
    targets: [
        .target(
            name: "Candle",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                "CandleSession",
            ]
        ),
        .binaryTarget(
            name: "CandleSession",
            path: "./CandleSession.xcframework"
        ),
    ]
)
