// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "pbrich",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "pbrich", targets: ["pbrich"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "pbrich",
            dependencies: ["PBRichCore"]
        ),
        .target(
            name: "PBRichCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "PBRichTests",
            dependencies: ["PBRichCore"]
        )
    ]
)
