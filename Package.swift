// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Stytch",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "StytchCore", targets: ["StytchCore"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "StytchCore"),
        .testTarget(name: "StytchCoreTests", dependencies: ["StytchCore"]),
    ]
)
