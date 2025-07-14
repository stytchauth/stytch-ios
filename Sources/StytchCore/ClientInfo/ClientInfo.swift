import Foundation
#if os(macOS)
import AppKit
#elseif os(watchOS)
import WatchKit
#else
import UIKit
#endif

public struct ClientInfo: Encodable {
    let app: App = .init()
    let sdk: SDK = .init()
    // swiftlint:disable:next identifier_name
    let os: OperatingSystem = .init()
    let device: Device = .init()

    public init() {}
}

public extension ClientInfo {
    struct App: Encodable {
        let identifier: String = Bundle.main.bundleIdentifier ?? "unknown_bundle_id"
    }

    struct SDK: Encodable {
        let identifier: String = "stytch-ios"
        let version: Version = .current
    }

    struct OperatingSystem: Encodable {
        private enum CodingKeys: String, CodingKey {
            case identifier
            case version
        }

        var identifier: String { operatingSystem.lowercased() }

        var version: Version { ProcessInfo.processInfo.operatingSystemVersion.version }

        private var operatingSystem: String {
            #if os(macOS)
            return "macOS"
            #elseif os(watchOS)
            WKInterfaceDevice.current().systemName
            #else
            return UIDevice.current.systemName
            #endif
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(identifier, forKey: .identifier)
            try container.encode(version, forKey: .version)
        }
    }

    struct Device: Encodable {
        private enum CodingKeys: String, CodingKey {
            case model
            case screenSize
        }

        var model: String {
            #if os(macOS)
            "macOS"
            #elseif os(watchOS)
            WKInterfaceDevice.current().model
            #else
            UIDevice.current.model.lowercased()
            #endif
        }

        var screenSize: CGSize {
            #if os(macOS)
            NSScreen.main?.frame.size ?? .zero
            #elseif os(watchOS)
            WKInterfaceDevice.current().screenBounds.size
            #elseif os(visionOS)
            CGSize(width: 800, height: 600)
            #else
            UIScreen.main.bounds.size
            #endif
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(model, forKey: .model)
            try container.encode("(\(screenSize.width),\(screenSize.height))", forKey: .screenSize)
        }
    }
}
