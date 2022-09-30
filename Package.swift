// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Networkable",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "Networkable",
            targets: ["Networkable"]),
        .library(
            name: "Reachability",
            targets: ["Reachability"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Networkable",
            dependencies: []),
        .testTarget(
            name: "NetworkableTests",
            dependencies: ["Networkable"]),
        .target(
            name: "Reachability",
            dependencies: []),
        .testTarget(
            name: "ReachabilityTests",
            dependencies: ["Reachability"]),
    ]
)
