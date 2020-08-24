// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
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
