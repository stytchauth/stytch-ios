import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO.SAML {
    struct SAMLConnection: Codable {
        let organizationId: String
        let connectionId: String
        let status: String
        let attributeMapping: [String: String]
        let idpEntityId: String
        let displayName: String
        let idpSsoUrl: String
        let acsUrl: String
        let audienceUri: String
        let signingCertificates: [X509Certificate]
        let verificationCertificates: [X509Certificate]
        let samlConnectionImplicitRoleAssignments: [ConnectionRoleAssignment]
        let samlGroupImplicitRoleAssignments: [GroupRoleAssignment]
        let identityProvider: String

        /// - Parameters:
        ///   - organizationId: Globally unique UUID that identifies a specific Organization.
        ///   - connectionId: Globally unique UUID that identifies a specific SAML Connection.
        ///   - status: The status of the connection. The possible values are `pending` or `active`.
        ///   See the https://stytch.com/docs/b2b/api/update-saml-connection Update SAML Connection endpoint for more details.
        ///   - attributeMapping: An object that represents the attributes used to identify a Member.
        ///   This object will map the IdP-defined User attributes to Stytch-specific values.
        ///   Required attributes: `email` and one of `full_name` or `first_name` and `last_name`.
        ///   - idpEntityId: A globally unique name for the IdP. This will be provided by the IdP.
        ///   - displayName: A human-readable display name for the connection.
        ///   - idpSsoUrl: The URL for which assertions for login requests will be sent. This will be provided by the IdP.
        ///   - acsUrl: The URL of the Assertion Consumer Service. This value will be passed to the IdP to redirect the Member back to Stytch after a sign-in attempt.
        ///   Read our https://stytch.com/docs/b2b/api/saml-overview SAML Overview for more info.
        ///   - audienceUri: The URL of the Audience Restriction. This value will indicate that Stytch is the intended audience of an assertion.
        ///   Read our https://stytch.com/docs/b2b/api/saml-overview SAML Overview for more info.
        ///   - signingCertificate: A list of X.509 certificates Stytch will use to sign its assertion requests.
        ///   Certificates should be uploaded to the IdP.
        ///   - verificationCertificates: A list of X.509 certificates Stytch will use to validate an assertion callback.
        ///   Certificates should be populated from the IdP.
        ///   - samlConnectionImplicitRoleAssignments: An array of implicit role assignments granted to members in this organization who log in with this SAML connection.
        ///   See our https://stytch.com/docs/b2b/guides/rbac/role-assignment RBAC guide for more information about role assignment.
        ///   - samlGroupImplicitRoleAssignments: An array of implicit role assignments granted to members in this organization who log in with this SAML connection and belong to the specified group.
        ///   See our https://stytch.com/docs/b2b/guides/rbac/role-assignment RBAC guide for more information about role assignment.
        ///   - identityProvider: The identity provider of this connection. For SAML, the accepted values are `generic`, `okta`, `microsoft-entra`, and 'google-workspace'.
        init(
            organizationId: String,
            connectionId: String,
            status: String,
            attributeMapping: [String: String],
            idpEntityId: String,
            displayName: String,
            idpSsoUrl: String,
            acsUrl: String,
            audienceUri: String,
            signingCertificates: [X509Certificate],
            verificationCertificates: [X509Certificate],
            samlConnectionImplicitRoleAssignments: [ConnectionRoleAssignment],
            samlGroupImplicitRoleAssignments: [GroupRoleAssignment],
            identityProvider: String
        ) {
            self.organizationId = organizationId
            self.connectionId = connectionId
            self.status = status
            self.attributeMapping = attributeMapping
            self.idpEntityId = idpEntityId
            self.displayName = displayName
            self.idpSsoUrl = idpSsoUrl
            self.acsUrl = acsUrl
            self.audienceUri = audienceUri
            self.signingCertificates = signingCertificates
            self.verificationCertificates = verificationCertificates
            self.samlConnectionImplicitRoleAssignments = samlConnectionImplicitRoleAssignments
            self.samlGroupImplicitRoleAssignments = samlGroupImplicitRoleAssignments
            self.identityProvider = identityProvider
        }
    }
}

public extension StytchB2BClient.SSO.SAML {
    struct X509Certificate: Codable {
        let certificateId: String
        let certificate: String
        let issuer: String
        let createdAt: String?
        let expiresAt: String?

        init(
            certificateId: String,
            certificate: String,
            issuer: String,
            createdAt: String?,
            expiresAt: String?
        ) {
            self.certificateId = certificateId
            self.certificate = certificate
            self.issuer = issuer
            self.createdAt = createdAt
            self.expiresAt = expiresAt
        }
    }

    struct ConnectionRoleAssignment: Codable {
        let roleId: String

        init(roleId: String) {
            self.roleId = roleId
        }
    }

    struct GroupRoleAssignment: Codable {
        let roleId: String
        let group: String

        init(
            roleId: String,
            group: String
        ) {
            self.roleId = roleId
            self.group = group
        }
    }
}
#endif
