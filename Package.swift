// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name = "SwiftyMime"

let package = Package(
    name: name,
    products: [
        .library(
            name: name,
            targets: [name]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftyMime",
            dependencies: []),
        .testTarget(
            name: "SwiftyMimeTests",
            dependencies: ["SwiftyMime"]),
    ]
)
