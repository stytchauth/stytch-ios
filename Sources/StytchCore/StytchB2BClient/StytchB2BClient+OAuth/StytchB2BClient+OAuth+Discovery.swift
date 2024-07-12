import Foundation

public extension StytchB2BClient.OAuth {
    /// The interface for interacting with OAuth products.
    var discovery: Discovery {
        .init(router: router.scopedRouter {
            $0.discoveryRoute
        })
    }
}

public extension StytchB2BClient.OAuth {
    struct Discovery {
        let router: NetworkingRouter<StytchB2BClient.OAuthRoute.DiscoveryRoute>

        @Dependency(\.keychainClient) private var keychainClient
        @Dependency(\.pkcePairManager) private var pkcePairManager

        // sourcery: AsyncVariants
        /// After an identity provider confirms the identity of a user, this method authenticates the included token and returns a new session object.
        public func authenticate(parameters: DiscoveryAuthenticateParameters) async throws -> DiscoveryAuthenticateResponse {
            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                try? await StytchB2BClient.events.logEvent(parameters: .init(eventName: "oauth_failure", error: StytchSDKError.missingPKCE))
                throw StytchSDKError.missingPKCE
            }
            do {
                let result = try await router.post(
                    to: .authenticate,
                    parameters: CodeVerifierParameters(codingPrefix: .pkce, codeVerifier: pkcePair.codeVerifier, wrapped: parameters)
                ) as DiscoveryAuthenticateResponse
                try? await StytchB2BClient.events.logEvent(parameters: .init(eventName: "oauth_success"))
                return result
            } catch {
                try? await StytchB2BClient.events.logEvent(parameters: .init(eventName: "oauth_failure", error: error))
                throw error
            }
        }
    }
}

public extension StytchB2BClient.OAuth.Discovery {
    struct DiscoveryAuthenticateParameters: Codable {
        public let discoveryOauthToken: String

        /// A data class wrapping the parameters necessary to authenticate an OAuth Discovery flow
        /// - Parameter discoveryOauthToken: The oauth token used to finish the discovery flow
        public init(discoveryOauthToken: String) {
            self.discoveryOauthToken = discoveryOauthToken
        }
    }
}

public extension StytchB2BClient.OAuth.Discovery {
    typealias DiscoveryAuthenticateResponse = Response<DiscoveryAuthenticateResponseData>

    struct DiscoveryAuthenticateResponseData: Codable {
        public let intermediateSessionToken: String
        public let emailAddress: String
        public let discoveredOrganizations: [DiscoveredOrganization]
    }

    struct DiscoveredOrganization: Codable {
        public let organization: Organization
        public let membership: Membership
        public let memberAuthenticated: Bool
    }

    struct Membership: Codable {
        public let type: String
        public let details: MembershipDetails?
        public let member: Member?
    }

    struct MembershipDetails: Codable {
        public let domain: String
    }
}
