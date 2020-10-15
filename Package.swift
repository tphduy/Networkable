// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v10),
        .tvOS(.v13),
        .watchOS(.v6)
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
