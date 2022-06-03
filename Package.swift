// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Stytch",
    platforms: [.iOS("11.3"), .macOS(.v10_13), .tvOS(.v11), .watchOS(.v4)],
    products: [
        .library(name: "StytchCore", targets: ["StytchCore"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "StytchCore"),
        .testTarget(name: "StytchCoreTests", dependencies: ["StytchCore"]),
    ]
)

#if swift(>=5.6)
// Add the documentation compiler plugin if possible
package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
)
#endif
