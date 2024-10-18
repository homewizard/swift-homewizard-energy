// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HWLocalAPI",
    platforms: [
        .macOS(.v13),
        .iOS(.v14),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HWLocalAPI",
            targets: ["HWLocalAPI"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HWLocalAPI",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency", .when(platforms: [.macOS, .iOS, .watchOS, .tvOS]))
            ]
        ),
        .testTarget(
            name: "HWLocalAPITests",
            dependencies: ["HWLocalAPI"]
        ),
    ]
)
