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

        @Dependency(\.pkcePairManager) private var pkcePairManager

        // sourcery: AsyncVariants
        /// After an identity provider confirms the identity of a user, this method authenticates the included token and returns a new session object.
        public func authenticate(parameters: DiscoveryAuthenticateParameters) async throws -> DiscoveryAuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                try? await EventsClient.logEvent(parameters: .init(eventName: "b2b_discovery_oauth_failure", error: StytchSDKError.missingPKCE))
                throw StytchSDKError.missingPKCE
            }

            do {
                let result = try await router.post(
                    to: .authenticate,
                    parameters: CodeVerifierParameters(codingPrefix: .pkce, codeVerifier: pkcePair.codeVerifier, wrapped: parameters)
                ) as DiscoveryAuthenticateResponse
                try? await EventsClient.logEvent(parameters: .init(eventName: "b2b_discovery_oauth_success"))
                return result
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "b2b_discovery_oauth_failure", error: error))
                throw error
            }
        }
    }
}

public extension StytchB2BClient.OAuth.Discovery {
    struct DiscoveryAuthenticateParameters: Codable {
        let discoveryOauthToken: String

        /// A data class wrapping the parameters necessary to authenticate an OAuth Discovery flow
        /// - Parameter discoveryOauthToken: The oauth token used to finish the discovery flow
        public init(discoveryOauthToken: String) {
            self.discoveryOauthToken = discoveryOauthToken
        }
    }
}

public extension StytchB2BClient.OAuth.Discovery {
    typealias DiscoveryAuthenticateResponse = Response<DiscoveryAuthenticateResponseData>

    struct DiscoveryAuthenticateResponseData: DiscoveryIntermediateSessionTokenDataType, Codable {
        /// The Intermediate Session Token. This token does not necessarily belong to a specific instance of a Member, but represents a bag of factors that may be converted to a member session.
        /// The token can be used with the OTP SMS Authenticate endpoint, TOTP Authenticate endpoint, or Recovery Codes Recover endpoint to complete an MFA flow and log in to the Organization.
        /// It can also be used with the Exchange Intermediate Session endpoint to join a specific Organization that allows the factors represented by the intermediate session token;
        /// or the Create Organization via Discovery endpoint to create a new Organization and Member.
        public let intermediateSessionToken: String
        /// The email address.
        public let emailAddress: String
        /// An array of discovered_organization objects tied to the intermediate_session_token, session_token, or session_jwt. See the Discovered Organization Object for complete details.
        /// Note that Organizations will only appear here under any of the following conditions:
        /// The end user is already a Member of the Organization.
        /// The end user is invited to the Organization.
        /// The end user can join the Organization because:
        /// a) The Organization allows JIT provisioning.
        /// b) The Organizations' allowed domains list contains the Member's email domain.
        /// c) The Organization has at least one other Member with a verified email address with the same domain as the end user (to prevent phishing attacks).
        public let discoveredOrganizations: [StytchB2BClient.DiscoveredOrganization]
    }
}
