// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Networking",
            dependencies: []),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"])
    ]
)
