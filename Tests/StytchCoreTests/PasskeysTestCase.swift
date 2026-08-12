import AuthenticationServices
import XCTest
@testable import StytchCore

// swiftlint:disable function_body_length

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
final class PasskeysTestCase: BaseTestCase {
    private typealias Base = StytchClient.Passkeys

    func testRegister() async throws {
        let userId: User.ID = "user_id_123"
        let webauthnRegistrationId: User.WebAuthNRegistration.ID = "webauthn-registration-id"
        let startResponse: Base.RegisterStartResponseData = .init(
            userId: userId,
            challenge: try Current.cryptoClient.dataWithRandomBytesOfCount(32),
            user: StytchClient.Passkeys.PasskeysUser(displayName: "My Stytch Username")
        )
        networkInterceptor.responses {
            Success {
                Response(requestId: "", statusCode: 200, wrapped: startResponse)
                Base.RegisterResponse(
                    requestId: "request_id_123",
                    statusCode: 200,
                    wrapped: .init(
                        userId: userId,
                        webauthnRegistrationId: webauthnRegistrationId,
                        user: .init(
                            createdAt: Current.date(),
                            cryptoWallets: [],
                            emails: [],
                            userId: userId,
                            name: .init(firstName: "first", lastName: "last", middleName: nil),
                            password: nil,
                            phoneNumbers: [],
                            providers: [],
                            status: .active,
                            totps: [],
                            webauthnRegistrations: [
                                .init(
                                    domain: "something.blah.com",
                                    authenticatorType: "platform",
                                    name: "My device passkey",
                                    userAgent: "iOS",
                                    verified: true,
                                    webauthnRegistrationId: webauthnRegistrationId
                                ),
                            ],
                            biometricRegistrations: [],
                            untrustedMetadata: nil,
                            trustedMetadata: nil
                        ),
                        sessionToken: "hello_session",
                        sessionJwt: "jwt_for_me",
                        session: .mock(userId: userId),
                        userDevice: nil
                    )
                )
            }
        }
        Current.passkeysClient.registerCredential = { _, _, _, _ in
            MockRegistration(
                rawAttestationObject: .init("fake_attestation_data".utf8),
                rawClientDataJSON: .init("fake_json".utf8),
                credentialID: .init("fake_id".utf8)
            )
        }
        let response = try await StytchClient.passkeys.register(parameters: .init(domain: "something.blah.com"))
        XCTAssertEqual(response.userId, userId)
        XCTAssertEqual(response.webauthnRegistrationId, webauthnRegistrationId)
        XCTAssertEqual(response.user.webauthnRegistrations.first?.authenticatorType, "platform")
        XCTAssertEqual(response.user.webauthnRegistrations.first?.name, "My device passkey")
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/webauthn/register/start",
            method: .post(["domain": "something.blah.com", "return_passkey_credential_options": true])
        )
        try XCTAssertRequestWithPublicKeyCredential(
            networkInterceptor.requests[1],
            urlString: "https://api.stytch.com/sdk/v1/webauthn/register",
            method: .post([
                "public_key_credential": "{\"rawId\":\"ZmFrZV9pZA\",\"id\":\"ZmFrZV9pZA\",\"response\":{\"clientDataJSON\":\"ZmFrZV9qc29u\",\"attestationObject\":\"ZmFrZV9hdHRlc3RhdGlvbl9kYXRh\"},\"type\":\"public-key\"}",
            ])
        )
    }

    func testRegisterWithNameOverrides() async throws {
        let userId: User.ID = "user_id_123"
        let startResponse: Base.RegisterStartResponseData = .init(
            userId: userId,
            challenge: try Current.cryptoClient.dataWithRandomBytesOfCount(32),
            user: StytchClient.Passkeys.PasskeysUser(displayName: "user@example.com")
        )
        networkInterceptor.responses {
            Success {
                Response(requestId: "", statusCode: 200, wrapped: startResponse)
                Base.RegisterResponse(
                    requestId: "request_id_123",
                    statusCode: 200,
                    wrapped: .init(
                        userId: userId,
                        webauthnRegistrationId: "webauthn-registration-id",
                        user: .init(
                            createdAt: Current.date(),
                            cryptoWallets: [],
                            emails: [],
                            userId: userId,
                            name: .init(firstName: "first", lastName: "last", middleName: nil),
                            password: nil,
                            phoneNumbers: [],
                            providers: [],
                            status: .active,
                            totps: [],
                            webauthnRegistrations: [],
                            biometricRegistrations: [],
                            untrustedMetadata: nil,
                            trustedMetadata: nil
                        ),
                        sessionToken: "hello_session",
                        sessionJwt: "jwt_for_me",
                        session: .mock(userId: userId),
                        userDevice: nil
                    )
                )
            }
        }
        var registeredUsername: String?
        Current.passkeysClient.registerCredential = { _, _, username, _ in
            registeredUsername = username
            return MockRegistration(
                rawAttestationObject: .init("fake_attestation_data".utf8),
                rawClientDataJSON: .init("fake_json".utf8),
                credentialID: .init("fake_id".utf8)
            )
        }
        _ = try await StytchClient.passkeys.register(
            parameters: .init(
                domain: "something.blah.com",
                overrideName: "user@example.com",
                overrideDisplayName: "user@example.com"
            )
        )
        XCTAssertEqual(registeredUsername, "user@example.com")
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/webauthn/register/start",
            method: .post([
                "domain": "something.blah.com",
                "return_passkey_credential_options": true,
                "override_name": "user@example.com",
                "override_display_name": "user@example.com",
            ])
        )
    }

    // Pins the live response shape: `allowCredentials` lives inside the JSON-string
    // `public_key_credential_request_options`, and the server encodes credential ids
    // as padded standard base64 (unlike the base64url challenge).
    func testAuthenticateStartResponseDecodesAllowCredentials() throws {
        let json = """
        {
            "user_id": "user-test-1234",
            "public_key_credential_request_options": "{\\"challenge\\":\\"KeCOE4Yt-JRCCTKqLHQL4pEIYvHThIB8fa65OuOFRFDD\\",\\"allowCredentials\\":[{\\"id\\":\\"OddU8QGULlaQC9nCup3ZIYpaJOk=\\",\\"type\\":\\"public-key\\"}]}"
        }
        """
        let response = try Current.jsonDecoder.decode(Base.AuthenticateStartResponseData.self, from: Data(json.utf8))
        XCTAssertEqual(response.allowCredentialIds, [Data(base64Encoded: "OddU8QGULlaQC9nCup3ZIYpaJOk=")])
    }

    // The server omits `allowCredentials` when the user isn't yet known (primary authentication).
    func testAuthenticateStartResponseDecodesMissingAllowCredentials() throws {
        let json = """
        {
            "user_id": "user-test-1234",
            "public_key_credential_request_options": "{\\"challenge\\":\\"KeCOE4Yt-JRCCTKqLHQL4pEIYvHThIB8fa65OuOFRFDD\\"}"
        }
        """
        let response = try Current.jsonDecoder.decode(Base.AuthenticateStartResponseData.self, from: Data(json.utf8))
        XCTAssertEqual(response.allowCredentialIds, [])
    }

    func testAuthenticate() async throws {
        let startResponse: Base.AuthenticateStartResponseData = .init(
            userId: "user_id_123",
            challenge: try Current.cryptoClient.dataWithRandomBytesOfCount(32)
        )
        networkInterceptor.responses {
            Response(requestId: "", statusCode: 200, wrapped: startResponse)
            AuthenticateResponse.mock
        }
        var requestBehaviorIsAutoFill = false
        var requestBehaviorIsPreferLocallyAvailableCredentials = false
        Current.passkeysClient.assertCredential = { _, _, allowedCredentialIds, requestBehavior in
            XCTAssertEqual(allowedCredentialIds, [])
            #if os(iOS)
            if case .autoFill = requestBehavior {
                requestBehaviorIsAutoFill = true
            }
            if case .options([.preferImmediatelyAvailableCredentials]) = requestBehavior {
                requestBehaviorIsPreferLocallyAvailableCredentials = true
            }
            #endif
            return MockAssertion(
                rawAuthenticatorData: .init("fake_auth_data".utf8),
                userID: .init("fake_user_id".utf8),
                signature: .init("fake_signature".utf8),
                rawClientDataJSON: .init("fake_json".utf8),
                credentialID: .init("fake_id".utf8)
            )
        }
        Current.timer = { _, _, _ in Self.mockTimer }
        #if os(iOS)
        let parameters: Base.AuthenticateParameters = .init(domain: "something.blah.com", requestBehavior: .options([.preferImmediatelyAvailableCredentials]))
        #else
        let parameters: Base.AuthenticateParameters = .init(domain: "something.blah.com")
        #endif
        _ = try await StytchClient.passkeys.authenticate(parameters: parameters)
        #if os(iOS)
        XCTAssertTrue(requestBehaviorIsPreferLocallyAvailableCredentials)
        #else
        XCTAssertFalse(requestBehaviorIsAutoFill)
        #endif
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/webauthn/authenticate/start/primary",
            method: .post(["domain": "something.blah.com", "return_passkey_credential_options": true])
        )
        try XCTAssertRequestWithPublicKeyCredential(
            networkInterceptor.requests[1],
            urlString: "https://api.stytch.com/sdk/v1/webauthn/authenticate",
            method: .post([
                "public_key_credential": "{\"rawId\":\"ZmFrZV9pZA\",\"id\":\"ZmFrZV9pZA\",\"response\":{\"clientDataJSON\":\"ZmFrZV9qc29u\",\"signature\":\"ZmFrZV9zaWduYXR1cmU\",\"authenticatorData\":\"ZmFrZV9hdXRoX2RhdGE\",\"userHandle\":\"ZmFrZV91c2VyX2lk\"},\"type\":\"public-key\"}",
                "session_duration_minutes": 5,
            ])
        )

        XCTAssertEqual(StytchClient.lastAuthMethodUsed, StytchClient.ConsumerAuthMethod.passkeys)
    }

    func testUpdate() async throws {
        networkInterceptor.responses {
            PasskeysUpdateResponse.mock
        }
        let parameters: Base.UpdateParameters = .init(
            id: "webauthn-registration-id",
            name: "Cool new name"
        )
        let response = try await StytchClient.passkeys.update(parameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/webauthn/update/webauthn-registration-id",
            method: .put(["name": "Cool new name"])
        )
        XCTAssertEqual(response.wrapped.webauthnRegistration.name, "Cool new name")
    }

    // Pins the live response shape: the updated registration is returned nested
    // under `webauthn_registration`, not as a top-level `webauthn_registration_id`.
    func testUpdateResponseDecoding() throws {
        let json = """
        {
            "request_id": "request-id-test-1234",
            "status_code": 200,
            "webauthn_registration": {
                "authenticator_type": "",
                "domain": "example.com",
                "name": "My passkey",
                "user_agent": "",
                "verified": true,
                "webauthn_registration_id": "webauthn-registration-id"
            }
        }
        """
        let response = try Current.jsonDecoder.decode(PasskeysUpdateResponse.self, from: Data(json.utf8))
        XCTAssertEqual(response.wrapped.webauthnRegistration.id, "webauthn-registration-id")
        XCTAssertEqual(response.wrapped.webauthnRegistration.name, "My passkey")
        XCTAssertEqual(response.wrapped.webauthnRegistration.domain, "example.com")
        XCTAssertTrue(response.wrapped.webauthnRegistration.verified)
    }
}

extension PasskeysUpdateResponse {
    static var mock: Self {
        .init(
            requestId: "1234",
            statusCode: 200,
            wrapped: .init(
                webauthnRegistration: .init(
                    domain: "example.com",
                    name: "Cool new name",
                    userAgent: "",
                    verified: true,
                    webauthnRegistrationId: "webauthn-registration-id"
                )
            )
        )
    }
}

// swiftlint:disable unavailable_function
final class MockAssertion: NSObject, ASAuthorizationPublicKeyCredentialAssertion {
    static var supportsSecureCoding: Bool = false

    var rawAuthenticatorData: Data

    var userID: Data

    var signature: Data

    var rawClientDataJSON: Data

    var credentialID: Data

    init(
        rawAuthenticatorData: Data,
        userID: Data,
        signature: Data,
        rawClientDataJSON: Data,
        credentialID: Data
    ) {
        self.rawAuthenticatorData = rawAuthenticatorData
        self.userID = userID
        self.signature = signature
        self.rawClientDataJSON = rawClientDataJSON
        self.credentialID = credentialID
    }

    init?(coder _: NSCoder) {
        fatalError("Unimplemented")
    }

    func copy(with _: NSZone? = nil) -> Any {
        fatalError("Unimplemented")
    }

    func encode(with _: NSCoder) {}
}

final class MockRegistration: NSObject, ASAuthorizationPublicKeyCredentialRegistration {
    static var supportsSecureCoding: Bool = false

    var rawAttestationObject: Data?

    var rawClientDataJSON: Data

    var credentialID: Data

    init(rawAttestationObject: Data, rawClientDataJSON: Data, credentialID: Data) {
        self.rawAttestationObject = rawAttestationObject
        self.rawClientDataJSON = rawClientDataJSON
        self.credentialID = credentialID
    }

    init?(coder _: NSCoder) {
        fatalError("Unimplemented")
    }

    func copy(with _: NSZone? = nil) -> Any {
        fatalError("Unimplemented")
    }

    func encode(with _: NSCoder) {}
}
// swiftlint:enable unavailable_function
#endif
