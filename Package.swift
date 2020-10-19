// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Networkable",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "Networkable",
            targets: ["Networkable"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Networkable",
            dependencies: []),
        .testTarget(
            name: "NetworkableTests",
            dependencies: ["Networkable"])
    ]
)
