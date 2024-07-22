import Foundation

// swiftlint:disable identifier_name

public extension StytchB2BClient {
    enum SsoJitProvisioning: String, Codable {
        case ALL_ALLOWED
        case RESTRICTED
        case NOT_ALLOWED
    }

    enum EmailJitProvisioning: String, Codable {
        case RESTRICTED
        case NOT_ALLOWED
    }

    enum EmailInvites: String, Codable {
        case ALL_ALLOWED
        case RESTRICTED
        case NOT_ALLOWED
    }

    enum AuthMethods: String, Codable {
        case ALL_ALLOWED
        case RESTRICTED
    }

    enum AllowedAuthMethods: String, Codable {
        case SSO = "sso"
        case MAGIC_LINK = "magic_link"
        case PASSWORD = "password"
        case GOOGLE_OAUTH = "google_oauth"
        case MICROSOFT_OAUTH = "microsoft_oauth"
    }

    enum MfaMethods: String, Codable {
        case ALL_ALLOWED
        case RESTRICTED
    }

    enum MfaMethod: String, Codable {
        case SMS = "sms_otp"
        case TOTP = "totp"
    }

    enum MfaPolicy: String, Codable {
        case REQUIRED_FOR_ALL
        case OPTIONAL
    }

    enum MFAEnrollment: String, Codable {
        case enroll
        case unenroll
    }

    struct RBACEmailImplicitRoleAssignments: Codable {
        let roleId: String
        let domain: String

        public init(roleId: String, domain: String) {
            self.roleId = roleId
            self.domain = domain
        }
    }

    struct SSOActiveConnection: Codable {
        let connectionId: String
        let displayName: String

        init(connectionId: String, displayName: String) {
            self.connectionId = connectionId
            self.displayName = displayName
        }
    }

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
