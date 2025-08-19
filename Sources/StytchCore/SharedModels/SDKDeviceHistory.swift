public struct SDKDeviceHistory: Codable, Sendable {
    let ipAddress: String?
    let ipAddressDetails: DeviceAttributeDetails?
    let ipGeoCity: String?
    let ipGeoRegion: String?
    let ipGeoCountry: String?
    let ipGeoCountryDetails: DeviceAttributeDetails?
}
