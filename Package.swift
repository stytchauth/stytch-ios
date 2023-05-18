// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Stytch",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "StytchCore", targets: ["StytchCore"]),
        .library(name: "StytchUI", targets: ["StytchUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: .init(3, 5, 9)),
    ],
    targets: [
        .target(
            name: "StytchUI",
            dependencies: [
                .target(name: "StytchCore"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
            ]
        ),
        .target(name: "StytchCore"),
        .testTarget(name: "StytchCoreTests", dependencies: ["StytchCore"]),
    ]
)
