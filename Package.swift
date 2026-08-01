// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GrowattToolbar",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "GrowattToolbarApp", targets: ["GrowattToolbarApp"]),
        .library(name: "GrowattToolbarCore", targets: ["GrowattToolbarCore"])
    ],
    targets: [
        .target(
            name: "GrowattToolbarCore",
            path: "src/GrowattToolbarCore"
        ),
        .executableTarget(
            name: "GrowattToolbarApp",
            dependencies: ["GrowattToolbarCore"],
            path: "src/GrowattToolbarApp",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "GrowattToolbarCoreTests",
            dependencies: ["GrowattToolbarCore"],
            path: "Tests/GrowattToolbarCoreTests"
        )
    ]
)
