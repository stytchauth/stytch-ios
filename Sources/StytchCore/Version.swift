import Foundation

struct Version: Encodable {
    let major: UInt
    let minor: UInt
    let patch: UInt

    var stringValue: String { "\(major).\(minor).\(patch)" }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

extension OperatingSystemVersion {
    var version: Version { .init(major: UInt(majorVersion), minor: UInt(minorVersion), patch: UInt(patchVersion)) }
}
