import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO {
    /// The interface for interacting with SAML SSO.
    var saml: SAML {
        .init(router: router.scopedRouter { $0.saml })
    }
}

public extension StytchB2BClient.SSO {
    // sourcery: ExcludeWatchOS
    struct SAML {
        let router: NetworkingRouter<StytchB2BClient.SSORoute.SAMLRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func createConnection(parameters: CreateConnectionParameters) async throws -> SAMLConnectionResponse {
            try await router.post(to: .createConnection, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func updateConnection(parameters: UpdateConnectionParameters) async throws -> SAMLConnectionResponse {
            try await router.put(to: .updateConnection(connectionId: parameters.connectionId), parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func updateConnectionByURL(parameters: UpdateConnectionByURLParameters) async throws -> SAMLConnectionResponse {
            try await router.put(to: .updateConnectionByURL(connectionId: parameters.connectionId), parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func deleteVerificationCertificate(parameters: DeleteVerificationCertificateParameters) async throws -> SAMLDeleteVerificationCertificateResponse {
            try await router.delete(route: .deleteVerificationCertificate(connectionId: parameters.connectionId, certificateId: parameters.certificateId))
        }
    }
}

public extension StytchB2BClient.SSO.SAML {
    struct CreateConnectionParameters: Codable {
        let displayName: String?
        let identityProvider: String?

        /// - Parameters:
        ///   - displayName: A human-readable display name for the connection.
        ///   - identityProvider: The identity provider of this connection. For SAML, the accepted varues are `generic`, `okta`, `microsoft-entra`, and 'google-workspace'.
        public init(displayName: String?, identityProvider: String?) {
            self.displayName = displayName
            self.identityProvider = identityProvider
        }
    }
}

public extension StytchB2BClient.SSO.SAML {
    struct UpdateConnectionParameters: Codable, Sendable {
        let connectionId: String
        let idpEntityId: String?
        let displayName: String?
        let attributeMapping: [String: String]?
        let idpSsoUrl: String?
        let x509Certificate: String?
        let samlConnectionImplicitRoleAssignment: [ConnectionRoleAssignment]?
        let samlGroupImplicitRoleAssignment: [GroupRoleAssignment]?
        let identityProvider: String?

        /// - Parameters:
        ///   - connectionId: Globally unique UUID that identifies a specific SAML Connection.
        ///   - idpEntityId: A globally unique name for the IdP. This will be provided by the IdP.
        ///   - displayName: A human-readable display name for the connection.
        ///   - attributeMapping: An object that represents the attributes used to identify a Member.
        ///   This object will map the IdP-defined User attributes to Stytch-specific values.
        ///   Required attributes: `email` and one of `full_name` or `first_name` and `last_name`.
        ///   - idpSsoUrl: The URL for which assertions for login requests will be sent. This will be provided by the IdP.
        ///   - x509Certificate: A certificate that Stytch will use to verify the sign-in assertion sent by the IdP,
        ///   in https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail PEM format.
        ///   See our https://stytch.com/docs/b2b/api/saml-certificates X509 guide for more info.
        ///   - samlConnectionImplicitRoleAssignment: An array of implicit role assignments granted to members in this organization who log in with this SAML connection.
        ///   See our https://stytch.com/docs/b2b/guides/rbac/role-assignment RBAC guide for more information about role assignment.
        ///   - samlGroupImplicitRoleAssignment: An array of implicit role assignments granted to members in this organization who log in with this SAML connection
        ///   and belong to the specified group. Before adding any group implicit role assignments, you must add a "groups" key to your SAML connection's
        ///   attribute_mapping. Make sure that your IdP is configured to correctly send the group information.
        ///   See our https://stytch.com/docs/b2b/guides/rbac/role-assignment RBAC guide for more information about role assignment.
        ///   - identityProvider: The identity provider of this connection. For SAML, the accepted values are `generic`, `okta`, `microsoft-entra`, and 'google-workspace'.
        public init(
            connectionId: String,
            idpEntityId: String? = nil,
            displayName: String? = nil,
            attributeMapping: [String: String]? = nil,
            idpSsoUrl: String? = nil,
            x509Certificate: String? = nil,
            samlConnectionImplicitRoleAssignment: [ConnectionRoleAssignment]? = nil,
            samlGroupImplicitRoleAssignment: [GroupRoleAssignment]? = nil,
            identityProvider: String? = nil
        ) {
            self.connectionId = connectionId
            self.idpEntityId = idpEntityId
            self.displayName = displayName
            self.attributeMapping = attributeMapping
            self.idpSsoUrl = idpSsoUrl
            self.x509Certificate = x509Certificate
            self.samlConnectionImplicitRoleAssignment = samlConnectionImplicitRoleAssignment
            self.samlGroupImplicitRoleAssignment = samlGroupImplicitRoleAssignment
            self.identityProvider = identityProvider
        }
    }
}

public extension StytchB2BClient.SSO.SAML {
    struct UpdateConnectionByURLParameters: Codable, Sendable {
        let connectionId: String
        let metadataUrl: String

        /// - Parameters:
        ///   - connectionId: Globally unique UUID that identifies a specific SAML Connection.
        ///   - metadataUrl: A URL that points to the IdP metadata. This will be provided by the IdP.
        public init(connectionId: String, metadataUrl: String) {
            self.connectionId = connectionId
            self.metadataUrl = metadataUrl
        }
    }
}

public extension StytchB2BClient.SSO.SAML {
    struct DeleteVerificationCertificateParameters: Codable, Sendable {
        let connectionId: String
        let certificateId: String

        /// - Parameters:
        ///   - connectionId: Globally unique UUID that identifies a specific SAML Connection.
        ///   - certificateId: The ID of the certificate to be deleted.
        public init(connectionId: String, certificateId: String) {
            self.connectionId = connectionId
            self.certificateId = certificateId
        }
    }
}

public extension StytchB2BClient.SSO.SAML {
    /// The response type for SAML connection calls.
    typealias SAMLConnectionResponse = Response<SAMLConnectionResponseData>

    /// The underlying data for the SAML connection type.
    struct SAMLConnectionResponseData: Codable, Sendable {
        /// The SAML Connection object affected by this API call.
        public let connection: SAMLConnection
    }
}

public extension StytchB2BClient.SSO.SAML {
    /// The response type for delete verification certificate calls.
    typealias SAMLDeleteVerificationCertificateResponse = Response<SAMLDeleteVerificationCertificateResponseData>

    /// The underlying data for the delete verification certificate type.
    struct SAMLDeleteVerificationCertificateResponseData: Codable, Sendable {
        /// The ID of the certificate that was deleted.
        public let certificateId: String
    }
}
#endif
