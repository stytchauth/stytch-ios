import Foundation

struct EncryptedUserDefaultsItem: Equatable {
    var kind: Kind = .encrypted
    var name: String

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}

extension EncryptedUserDefaultsItem {
    enum Kind {
        case encrypted
    }
}

extension EncryptedUserDefaultsItem {
    static let biometricKeyRegistration: Self = .init(name: "stytch_biometric_key_registration")

    static let sessionToken: Self = .init(name: SessionToken.Kind.opaque.name)
    static let sessionJwt: Self = .init(name: SessionToken.Kind.jwt.name)
    static let intermediateSessionToken: Self = .init(name: "stytch_intermediate_session_token")

    static let codeVerifierPKCE: Self = .init(name: "stytch_code_verifier_pkce")
    static let codeChallengePKCE: Self = .init(name: "stytch_code_challenge_pkce")

    static let session: Self = .init(name: "stytch_session_object")
    static let memberSession: Self = .init(name: "stytch_member_session_object")
    static let user: Self = .init(name: "stytch_user_object")
    static let member: Self = .init(name: "stytch_member_object")
    static let organization: Self = .init(name: "stytch_organization_object")

    static let b2bLastAuthMethodUsed: Self = .init(name: "b2b_last_auth_method_used")
    static let consumerLastAuthMethodUsed: Self = .init(name: "consumer_last_auth_method_used")

    static let lastAuthenticatedUserId: Self = .init(name: "stytch_last_authenticated_user_id")

    static func lastValidatedAtDate(_ prefix: String) -> Self {
        .init(name: "\(prefix)_last_validated_at_date")
    }

    static func biometricPendingDeleteFor(_ userId: String) -> Self {
        .init(name: "stytch_biometric_registration_pending_delete_for_\(userId)")
    }
}
