// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DaisyUIComponents",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "DaisyUIComponents",
            targets: ["DaisyUIComponents"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DaisyUIComponents",
            dependencies: []),
        .testTarget(
            name: "DaisyUIComponentsTests",
            dependencies: ["DaisyUIComponents"]),
    ]
)
