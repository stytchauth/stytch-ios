import Foundation

public struct DeviceHistory: Codable, Sendable {
    let visitorId: String?
    let visitorIdDetails: DeviceAttributeDetails?
    let ipAddress: String?
    let ipAddressDetails: DeviceAttributeDetails?
    let ipGeoCountry: String?
    let ipGeoCountryDetails: DeviceAttributeDetails?
    let ipGeoCity: String?
    let ipGeoRegion: String?
}

public struct DeviceAttributeDetails: Codable, Sendable {
    let isNew: Bool?
    let firstSeenAt: String?
    let lastSeenAt: String?
}
