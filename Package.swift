// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "RequestEasy",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "RequestEasy",
            targets: ["RequestEasy"]),
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
