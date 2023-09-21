// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Stytch",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "StytchCore", targets: ["StytchCore", "RecaptchaEnterprise"]),
    ],
    targets: [
        .target(
            name: "StytchCore",
            dependencies: [
                .target(name: "RecaptchaEnterprise", condition: .when(platforms: [.iOS])),
            ],
            resources: [
                .copy("DFPClient/dfp.html"),
            ]
        ),
        .binaryTarget(name: "RecaptchaEnterprise", path: "libs/recaptcha-xcframework.xcframework.zip"),
        .testTarget(name: "StytchCoreTests", dependencies: ["StytchCore"]),
    ]
)
