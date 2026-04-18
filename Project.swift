import ProjectDescription

let project = Project(
    name: "ZenKit",
    organizationName: "zenshi",
    packages: [
        .package(path: ".")
    ],
    targets: [
        .target(
            name: "ZenKitShowcase",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.zenshi.ZenKitShowcase",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:]
            ]),
            buildableFolders: [
                "App/ZenKitShowcase/Sources",
//                "App/ZenKitShowcase/Resources"
            ],
            dependencies: [
                .package(product: "ZenKit")
            ]
        ),
        .target(
            name: "ZenKitShowcaseTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.zenshi.ZenKitShowcaseTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: [
                "App/ZenKitShowcase/Tests"
            ],
            dependencies: [
                .target(name: "ZenKitShowcase")
            ]
        )
    ]
)
