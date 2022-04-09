// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stytch",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "StytchCore", targets: ["StytchCore"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "StytchCore", dependencies: ["Networking"]),
        .target(name: "Networking", dependencies: []),
        .testTarget(name: "StytchTests", dependencies: ["StytchCore"]),
    ]
)
