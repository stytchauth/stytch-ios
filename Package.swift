// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Stytch",
    platforms: [.iOS("11.3"), .macOS(.v10_13), .tvOS(.v11), .watchOS(.v4)],
    products: [
        .library(name: "StytchCore", targets: ["StytchCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
    ],
    targets: [
        .target(
            name: "StytchCore",
            dependencies: [
                "Networking",
                .product(name: "Tagged", package: "swift-tagged")
            ]
        ),
        .target(name: "Networking"),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"]),
        .testTarget(name: "StytchCoreTests", dependencies: ["StytchCore"]),
    ]
)
