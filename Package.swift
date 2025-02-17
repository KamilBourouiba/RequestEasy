// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "RequestEasy",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "RequestEasy",
            targets: ["RequestEasy"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "RequestEasy",
            dependencies: []),
        .testTarget(
            name: "RequestEasyTests",
            dependencies: ["RequestEasy"]),
    ]
)
