// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZenKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "ZenKit",
            targets: ["ZenKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jakub-kalamarz/ZenAvatar.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "ZenKit",
            dependencies: [
                .product(name: "ZenAvatar", package: "ZenAvatar")
            ]
        ),
        .testTarget(
            name: "ZenKitTests",
            dependencies: ["ZenKit"]
        ),
    ]
)
