import Foundation
import StytchCore

enum SSODiscoveryManager {
    private(set) static var ssoActiveConnections: [StytchB2BClient.SSOActiveConnection] = []

    static func fetchSSODiscoveryConnections(_ emailAddress: String) async throws -> [StytchB2BClient.SSOActiveConnection] {
        let response: StytchB2BClient.SSO.DiscoverConnectionsResponse = try await StytchB2BClient.sso.discoverConnections(emailAddress: emailAddress)
        ssoActiveConnections = response.connections
        return ssoActiveConnections
    }

    static func reset() {
        ssoActiveConnections = []
    }
}
