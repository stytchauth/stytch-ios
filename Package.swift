// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Stytch",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "StytchCore", targets: ["StytchCore"]),
        .library(name: "StytchUI", targets: ["StytchUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.1.4"),
        .package(url: "https://github.com/GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk", from: "18.8.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
        .package(url: "https://github.com/stytchauth/stytch-ios-dfp.git", from: "1.0.4"),
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
                .product(name: "StytchDFP", package: "stytch-ios-dfp", condition: .when(platforms: [.iOS])),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
        .testTarget(name: "StytchCoreTests", dependencies: ["StytchCore"]),
        .testTarget(name: "StytchUIUnitTests", dependencies: ["StytchCore", "StytchUI"]),
    ]
)
