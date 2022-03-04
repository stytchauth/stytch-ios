// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stytch",
    products: [
        .library(name: "Stytch", targets: ["Stytch"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Stytch", dependencies: []),
        .testTarget(name: "StytchTests", dependencies: ["Stytch"]),
    ]
)
