import Foundation

public extension StytchB2BClient {
    /// The interface for interacting with discovery products.
    static var discovery: Discovery {
        .init(router: router.scopedRouter {
            $0.discovery
        })
    }
}

public extension StytchB2BClient {
    /**
     * The Discovery product lets End Users discover and log in to Organizations they are a Member of, invited to, or eligible to join.
     * Unlike our other B2B products, Discovery allows End Users to authenticate without specifying an Organization in advance. This is done via a [Discovery Magic Link](https://stytch.com/docs/b2b/sdks/javascript-sdk#email-magic-links_methods_send-discovery-email) flow. After an End User is [authenticated](https://stytch.com/docs/b2b/sdks/javascript-sdk#email-magic-links_methods_authenticate-discovery-magic-link), an Intermediate Session is returned along with a list of associated Organizations.
     * The End User can then authenticate to the desired Organization by passing the Intermediate Session and `organization_id`. End users can even create a new Organization instead of joining or logging in to an existing one.
     */
    struct Discovery {
        let router: NetworkingRouter<DiscoveryRoute>

        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [list discovered Organizations](https://stytch.com/docs/b2b/api/list-discovered-organizations) endpoint. If the `intermediate_session_token` is not passed in and there is a current Member Session, the SDK will call the endpoint with the session token.
        public func listOrganizations() async throws -> ListOrganizationsResponse {
            try await router.post(
                to: .organizations,
                parameters: IntermediateSessionTokenParametersWithNoWrappedValue(
                    intermediateSessionToken: sessionManager.intermediateSessionToken
                )
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [exchange intermediate session](https://stytch.com/docs/b2b/api/exchange-intermediate-session) endpoint. This operation consumes the `intermediate_session_token`. If this method succeeds, the Member will be logged in, and granted an active session.
        public func exchangeIntermediateSession(parameters: ExchangeIntermediateSessionParameters) async throws -> B2BMFAAuthenticateResponse {
            try await router.post(
                to: .intermediateSessionsExchange,
                parameters: IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionManager.intermediateSessionToken,
                    wrapped: parameters
                )
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [create Organization via discovery](https://stytch.com/docs/b2b/api/create-organization-via-discovery) endpoint. This operation consumes the `intermediate_session_token`. If this method succeeds, the Member will be logged in, and granted an active session.
        public func createOrganization(parameters: CreateOrganizationParameters) async throws -> B2BMFAAuthenticateResponse {
            try await router.post(
                to: .organizationsCreate,
                parameters: IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionManager.intermediateSessionToken,
                    wrapped: parameters
                )
            )
        }
    }
}

public extension StytchB2BClient.Discovery {
    /// The response type for Discovery `listOrganizations` calls.
    typealias ListOrganizationsResponse = Response<ListOrganizationsResponseData>

    /// The underlying data for `ListOrganizationsResponse`
    struct ListOrganizationsResponseData: Codable, Sendable {
        /// The member's email address.
        public let emailAddress: String
        /// A list of discovered organizations.
        public let discoveredOrganizations: [StytchB2BClient.DiscoveredOrganization]
    }
}

public extension StytchB2BClient.Discovery {
    /// The dedicated parameters type for Discovery `exchangeIntermediateSession` calls.
    struct ExchangeIntermediateSessionParameters: Encodable, Sendable {
        let organizationId: Organization.ID
        let sessionDurationMinutes: Minutes
        let locale: StytchLocale

        /// - Parameters:
        ///   - organizationId: Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value.
        ///   - sessionDurationMinutes: The duration, in minutes, for the requested session. Defaults to 5 minutes.
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(
            organizationId: Organization.ID,
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            locale: StytchLocale = .en
        ) {
            self.organizationId = organizationId
            self.sessionDurationMinutes = sessionDurationMinutes
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.Discovery {
    /// A dedicated parameters type for Discovery `createOrganization` calls.
    struct CreateOrganizationParameters: Codable, Sendable {
        let sessionDurationMinutes: Minutes
        let organizationName: String?
        let organizationSlug: String?
        let organizationLogoUrl: URL?
        let ssoJitProvisioning: StytchB2BClient.SsoJitProvisioning?
        let emailAllowedDomains: [String]?
        let emailJitProvisioning: StytchB2BClient.EmailJitProvisioning?
        let emailInvites: StytchB2BClient.EmailInvites?
        let authMethods: StytchB2BClient.AuthMethods?
        let allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]?

        /// - Parameters:
        ///   - sessionDurationMinutes: The duration, in minutes, for the requested session. Defaults to 5 minutes.
        ///   - organizationName: The name of the Organization. If the name is not specified, a default name will be created based on the email used to initiate the discovery flow. If the email domain is a common email provider such as gmail.com, or if the email is a .edu email, the organization name will be generated based on the name portion of the email. Otherwise, the organization name will be generated based on the email domain.
        ///   - organizationSlug: The unique URL slug of the Organization. A minimum of two characters is required. The slug only accepts alphanumeric characters and the following reserved characters: - . _ ~. If the slug is not specified, a default slug will be created based on the email used to initiate the discovery flow. If the email domain is a common email provider such as gmail.com, or if the email is a .edu email, the organization slug will be generated based on the name portion of the email. Otherwise, the organization slug will be generated based on the email domain.
        ///   - organizationLogoUrl: The image URL of the Organization logo.
        ///   - ssoJitProvisioning: The authentication setting that controls the JIT provisioning of Members when authenticating via SSO.
        ///   - emailAllowedDomains: An array of email domains that allow invites or JIT provisioning for new Members. This list is enforced when either `email_invites` or `email_jit_provisioning` is set to `RESTRICTED`.
        ///   - emailJitProvisioning: The authentication setting that controls how a new Member can be provisioned by authenticating via Email Magic Link.
        ///   - emailInvites: The authentication setting that controls how a new Member can be invited to an organization by email.
        ///   - authMethods: The setting that controls which authentication methods can be used by Members of an Organization.
        ///   - allowedAuthMethods: An array of allowed authentication methods. This list is enforced when `auth_methods` is set to `RESTRICTED`.
        public init(
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            organizationName: String? = nil,
            organizationSlug: String? = nil,
            organizationLogoUrl: URL? = nil,
            ssoJitProvisioning: StytchB2BClient.SsoJitProvisioning? = nil,
            emailAllowedDomains: [String]? = nil,
            emailJitProvisioning: StytchB2BClient.EmailJitProvisioning? = nil,
            emailInvites: StytchB2BClient.EmailInvites? = nil,
            authMethods: StytchB2BClient.AuthMethods? = nil,
            allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]? = nil
        ) {
            self.sessionDurationMinutes = sessionDurationMinutes
            self.organizationName = organizationName
            self.organizationSlug = organizationSlug
            self.organizationLogoUrl = organizationLogoUrl
            self.ssoJitProvisioning = ssoJitProvisioning
            self.emailAllowedDomains = emailAllowedDomains
            self.emailJitProvisioning = emailJitProvisioning
            self.emailInvites = emailInvites
            self.authMethods = authMethods
            self.allowedAuthMethods = allowedAuthMethods
        }
    }
}
