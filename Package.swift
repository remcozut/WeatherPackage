// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "WeatherPackage",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "WeatherPackage",
            targets: ["WeatherPackage"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            from: "5.6.0"
        ),
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "WeatherPackage",
            dependencies: [
                "Alamofire",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            path: "Sources/WeatherPackage",
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"], .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "WeatherPackageTests",
            dependencies: ["WeatherPackage"],
            path: "Tests/WeatherPackageTests"
        ),
    ]
)
