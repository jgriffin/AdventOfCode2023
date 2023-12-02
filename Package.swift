// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AdventOfCode2023",
    platforms: [
        .macOS(.v13), .iOS(.v17),
    ],
    products: [
        .library(
            name: "AdventOfCode2023",
            targets: ["AdventOfCode2023"]
        ),
    ],
    dependencies: [
        .package(path: "../EulerTools"), // .package(url: "https://github.com/jgriffin/EulerTools.git", from: "0.3.2"),
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.13.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AdventOfCode2023",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "EulerTools", package: "EulerTools"),
            ]
        ),
        .testTarget(
            name: "AdventOfCode2023Tests",
            dependencies: ["AdventOfCode2023"],
            resources: [.process("resources")]
        ),
    ]
)
