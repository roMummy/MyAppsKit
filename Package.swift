// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MyAppsKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "MyAppsCore",
            targets: ["MyAppsCore"]
        ),
        .library(
            name: "MyAppsUI",
            targets: ["MyAppsUI"]
        )
    ],
    targets: [
        .target(
            name: "MyAppsCore"
        ),
        .target(
            name: "MyAppsUI",
            dependencies: ["MyAppsCore"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
