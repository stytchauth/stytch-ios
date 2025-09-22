import Foundation

public struct Version: Encodable {
    let major: UInt
    let minor: UInt
    let patch: UInt

    var stringValue: String { "\(major).\(minor).\(patch)" }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

public extension OperatingSystemVersion {
    var version: Version { .init(major: UInt(majorVersion), minor: UInt(minorVersion), patch: UInt(patchVersion)) }
}
