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
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", .exact("3.5.9")),
        .package(url: "https://github.com/GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk", .exact("18.4.0")),
    ],
    targets: [
        .target(
            name: "StytchUI",
            dependencies: [
                .target(name: "StytchCore"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
        .target(
            name: "StytchCore",
            dependencies: [
                .product(name: "RecaptchaEnterprise", package: "recaptcha-enterprise-mobile-sdk", condition: .when(platforms: [.iOS])),
            ],
            resources: [
                .copy("DFPClient/dfp.html"),
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
        .testTarget(name: "StytchCoreTests", dependencies: ["StytchCore"]),
        .testTarget(name: "StytchUIUnitTests", dependencies: ["StytchCore", "StytchUI"]),
    ]
)
