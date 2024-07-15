import Foundation

public extension StytchB2BClient {
    /**
     * The Discovery product lets End Users discover and log in to Organizations they are a Member of, invited to, or eligible to join.
     * Unlike our other B2B products, Discovery allows End Users to authenticate without specifying an Organization in advance. This is done via a [Discovery Magic Link](https://stytch.com/docs/b2b/sdks/javascript-sdk#email-magic-links_methods_send-discovery-email) flow. After an End User is [authenticated](https://stytch.com/docs/b2b/sdks/javascript-sdk#email-magic-links_methods_authenticate-discovery-magic-link), an Intermediate Session is returned along with a list of associated Organizations.
     * The End User can then authenticate to the desired Organization by passing the Intermediate Session and `organization_id`. End users can even create a new Organization instead of joining or logging in to an existing one.
     */
    struct Discovery {
        let router: NetworkingRouter<DiscoveryRoute>

        @Dependency(\.sessionStorage) private var sessionStorage

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [list discovered Organizations](https://stytch.com/docs/b2b/api/list-discovered-organizations) endpoint. If the `intermediate_session_token` is not passed in and there is a current Member Session, the SDK will call the endpoint with the session token.
        public func listOrganizations(parameters: ListOrganizationsParameters) async throws -> ListOrganizationsResponse {
            // TODO: IST - ADD
            try await router.post(to: .organizations, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [exchange intermediate session](https://stytch.com/docs/b2b/api/exchange-intermediate-session) endpoint. This operation consumes the `intermediate_session_token`. If this method succeeds, the Member will be logged in, and granted an active session.
        public func exchangeIntermediateSession(parameters: ExchangeIntermediateSessionParameters) async throws -> ExchangeIntermediateSessionResponse {
            // TODO: IST - ADD
            try await router.post(to: .intermediateSessionsExchange, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [create Organization via discovery](https://stytch.com/docs/b2b/api/create-organization-via-discovery) endpoint. This operation consumes the `intermediate_session_token`. If this method succeeds, the Member will be logged in, and granted an active session.
        public func createOrganization(parameters: CreateOrganizationParameters) async throws -> CreateOrganizationResponse {
            // TODO: IST - ADD
            try await router.post(to: .organizationsCreate, parameters: parameters)
        }
    }
}

public extension StytchB2BClient {
    /// The interface for interacting with discovery products.
    static var discovery: Discovery { .init(router: router.scopedRouter { $0.discovery }) }
}

public extension StytchB2BClient.Discovery {
    /// The response type for Discovery `listOrganizations` calls.
    typealias ListOrganizationsResponse = Response<ListOrganizationsResponseData>

    /// The underlying data for `ListOrganizationsResponse`
    struct ListOrganizationsResponseData: Codable {
        private enum CodingKeys: String, CodingKey {
            case email = "emailAddress"
            case discoveredOrganizations
        }

        /// The member's email address.
        public let email: String
        /// A list of discovered organizations.
        public let discoveredOrganizations: [DiscoveredOrganization]
    }

    /// A dedicated parameters type for Discover `listOrganizations` calls.
    struct ListOrganizationsParameters: Encodable {
        let intermediateSessionToken: String // TODO: IST

        /// - Parameter intermediateSessionToken: The Intermediate Session Token. This token does not belong to a specific instance of a member, but may be exchanged for an existing Member Session or used to create a new organization.
        public init(intermediateSessionToken: String) {
            self.intermediateSessionToken = intermediateSessionToken
        }
    }
}

public extension StytchB2BClient.Discovery {
    /// The response type for Discovery `exchangeIntermediateSession` calls.
    typealias ExchangeIntermediateSessionResponse = Response<ExchangeIntermediateSessionResponseData>

    /// The underlying data for `ExchangeIntermediateSessionResponse`.
    struct ExchangeIntermediateSessionResponseData: Codable, B2BAuthenticateResponseDataType {
        /// The current member's ID.
        public let memberId: Member.ID
        /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
        public let memberSession: MemberSession
        /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
        public let sessionToken: String
        /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
        public let sessionJwt: String
        /// The current member object.
        public let member: Member
        /// The current organization object.
        public let organization: Organization

        // TODO: IST - I THINK THIS RETURNS A IST ALSO
    }

    /// The dedicated parameters type for Discovery `exchangeIntermediateSession` calls.
    struct ExchangeIntermediateSessionParameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case intermediateSessionToken
            case organizationId
            case sessionDuration = "sessionDurationMinutes"
        }

        let intermediateSessionToken: String // TODO: IST
        let organizationId: Organization.ID
        let sessionDuration: Minutes

        /// - Parameters:
        ///   - intermediateSessionToken: The Intermediate Session Token. This token does not belong to a specific instance of a member, but may be exchanged for a Member Session or used to create a new organization.
        ///   - organizationId: Globally unique UUID that identifies a specific Organization. The `organization_id` is critical to perform operations on an Organization, so be sure to preserve this value.
        ///   - sessionDuration: The duration, in minutes, for the requested session. Defaults to 30 minutes.
        public init(intermediateSessionToken: String, organizationId: Organization.ID, sessionDuration: Minutes = .defaultSessionDuration) {
            self.intermediateSessionToken = intermediateSessionToken
            self.organizationId = organizationId
            self.sessionDuration = sessionDuration
        }
    }
}

public extension StytchB2BClient.Discovery {
    /// The response type for Discovery `createOrganization` calls.
    typealias CreateOrganizationResponse = Response<CreateOrganizationResponseData>

    /// The underlying data for `CreateOrganizationResponse`.
    struct CreateOrganizationResponseData: Codable, B2BAuthenticateResponseDataType {
        /// The current member's ID.
        public let memberId: Member.ID
        /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
        public let memberSession: MemberSession
        /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
        public let sessionToken: String
        /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
        public let sessionJwt: String
        /// The current member object.
        public let member: Member
        /// The current organization object.
        public let organization: Organization

        // TODO: IST - I THINK THIS RETURNS A IST ALSO
    }

    /// A dedicated parameters type for Discovery `createOrganization` calls.
    struct CreateOrganizationParameters: Codable {
        private enum CodingKeys: String, CodingKey {
            case intermediateSessionToken
            case sessionDuration = "sessionDurationMinutes"
            case organizationName
            case organizationSlug
            case organizationLogoUrl
            case ssoJitProvisioning
            case emailAllowedDomains
            case emailJitProvisioning
            case emailInvites
            case authMethods
            case allowedAuthMethods
        }

        let intermediateSessionToken: String // TODO: IST
        let sessionDuration: Minutes
        let organizationName: String?
        let organizationSlug: String?
        let organizationLogoUrl: URL?
        let ssoJitProvisioning: SsoJitProvisioning?
        let emailAllowedDomains: [String]?
        let emailJitProvisioning: EmailJitProvisioning?
        let emailInvites: EmailInvites?
        let authMethods: AuthMethods?
        let allowedAuthMethods: [AllowedAuthMethods]?

        /// - Parameters:
        ///   - intermediateSessionToken: The Intermediate Session Token. This token does not belong to a specific instance of a member, but may be exchanged for a Member Session or used to create a new organization.
        ///   - sessionDuration: The duration, in minutes, for the requested session. Defaults to 30 minutes.
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
            intermediateSessionToken: String,
            sessionDuration: Minutes = .defaultSessionDuration,
            organizationName: String? = nil,
            organizationSlug: String? = nil,
            organizationLogoUrl: URL? = nil,
            ssoJitProvisioning: SsoJitProvisioning? = nil,
            emailAllowedDomains: [String]? = nil,
            emailJitProvisioning: EmailJitProvisioning? = nil,
            emailInvites: EmailInvites? = nil,
            authMethods: AuthMethods? = nil,
            allowedAuthMethods: [AllowedAuthMethods]? = nil
        ) {
            self.intermediateSessionToken = intermediateSessionToken
            self.sessionDuration = sessionDuration
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

        /// The allowed values for `CreateOrganizationParameters.ssoJitProvisioning`.
        public enum SsoJitProvisioning: String, Codable {
            case allAllowed = "ALL_ALLOWED"
            case restricted = "RESTRICTED"
            case notAllowed = "NOT_ALLOWED"
        }

        /// The allowed values for `CreateOrganizationParameters.emailJitProvisioning`.
        public enum EmailJitProvisioning: String, Codable {
            case restricted = "RESTRICTED"
            case notAllowed = "NOT_ALLOWED"
        }

        /// The allowed values for `CreateOrganizationParameters.emailInvites`.
        public enum EmailInvites: String, Codable {
            case allAllowed = "ALL_ALLOWED"
            case restricted = "RESTRICTED"
            case notAllowed = "NOT_ALLOWED"
        }

        /// The allowed values for `CreateOrganizationParameters.authMethods`.
        public enum AuthMethods: String, Codable {
            case allAllowed = "ALL_ALLOWED"
            case restricted = "RESTRICTED"
        }

        /// The allowed values for `CreateOrganizationParameters.allowedAuthMethods`.
        public enum AllowedAuthMethods: String, Codable {
            case sso
            case magicLink = "magic_link"
            case password
        }
    }
}

public extension StytchB2BClient.Discovery {
    /// A discovered organization.
    struct DiscoveredOrganization: Codable {
        /// The organization.
        public let organization: Organization
        /// The membership and associated details.
        public let membership: Membership
        /// A boolean describing the member's authentication status.
        public let memberAuthenticated: Bool
    }

    /// A struct describing a membership and its details.
    struct Membership: Codable {
        private enum CodingKeys: String, CodingKey {
            case kind = "type"
            case details
            case member
        }

        /// The kind of membership.
        public let kind: String
        /// The details of the membership.
        public let details: JSON?
        /// The member.
        public let member: Member
    }
}
