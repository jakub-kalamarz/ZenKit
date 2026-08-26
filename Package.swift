// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZenKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "ZenKit",
            targets: ["ZenKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jakub-kalamarz/ZenAvatar.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "ZenKit",
            dependencies: [
                .product(name: "ZenAvatar", package: "ZenAvatar")
            ],
            exclude: [
                "Icons/hugeicons-manifest.json"
            ],
            resources: [
                .process("Icons/Resources")
            ]
        ),
        .testTarget(
            name: "ZenKitTests",
            dependencies: ["ZenKit"]
        ),
    ]
)
