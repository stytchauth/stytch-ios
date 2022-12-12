import AuthenticationServices
import XCTest
@testable import StytchCore

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
final class PasskeysTestCase: BaseTestCase {
    func testRegister() async throws {
        var requests: [URLRequest] = []
        let startResponse: Response<StytchClient.Passkeys.RegisterStartResponseData> = .init(
            requestId: "123",
            statusCode: 200,
            wrapped: .init(userId: "user_id_123", challenge: try Current.cryptoClient.dataWithRandomBytesOfCount(32))
        )
        Current.networkingClient = try .success(
            verifyingRequest: { requests.append($0) },
            startResponse,
            BasicResponse(requestId: "request_id_123", statusCode: 200)
        )
        Current.passkeysClient.registerCredential = { _, _, _, _ in
            MockRegistration(
                rawAttestationObject: .init("fake_attestation_data".utf8),
                rawClientDataJSON: .init("fake_json".utf8),
                credentialID: .init("fake_id".utf8)
            )
        }
        _ = try await StytchClient.passkeys.register(parameters: .init(domain: "something.blah.com", username: "test@stytch.com"))
        try XCTAssertRequest(requests[0], urlString: "https://web.stytch.com/sdk/v1/webauthn/register/start", method: .post, body: [
            "username": "test@stytch.com",
            "domain": "something.blah.com",
        ])
        try XCTAssertRequest(requests[1], urlString: "https://web.stytch.com/sdk/v1/webauthn/register", method: .post, body: [
            "public_key_credential": "{\"rawId\":\"ZmFrZV9pZA\",\"id\":\"ZmFrZV9pZA\",\"response\":{\"clientDataJSON\":\"ZmFrZV9qc29u\",\"attestationObject\":\"ZmFrZV9hdHRlc3RhdGlvbl9kYXRh\"},\"type\":\"public-key\"}",
        ])
    }

    func testAuthenticate() async throws {
        var requests: [URLRequest] = []
        let startResponse: Response<StytchClient.Passkeys.AuthenticateStartResponseData> = .init(
            requestId: "123",
            statusCode: 200,
            wrapped: .init(userId: "user_id_123", challenge: try Current.cryptoClient.dataWithRandomBytesOfCount(32))
        )
        Current.networkingClient = try .success(verifyingRequest: { requests.append($0) }, startResponse, AuthenticateResponse.mock)
        var requestBehaviorIsAutoFill = false
        Current.passkeysClient.assertCredential = { _, _, requestBehavior in
            #if os(iOS)
            if case .autoFill = requestBehavior {
                requestBehaviorIsAutoFill = true
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
        Current.timer = { _, _, _ in .init() }
        #if os(iOS)
        let parameters: StytchClient.Passkeys.AuthenticateParameters = .init(domain: "something.blah.com", requestBehavior: .autoFill)
        #else
        let parameters: StytchClient.Passkeys.AuthenticateParameters = .init(domain: "something.blah.com")
        #endif
        _ = try await StytchClient.passkeys.authenticate(parameters: parameters)
        #if os(iOS)
        XCTAssertTrue(requestBehaviorIsAutoFill)
        #else
        XCTAssertFalse(requestBehaviorIsAutoFill)
        #endif
        try XCTAssertRequest(requests[0], urlString: "https://web.stytch.com/sdk/v1/webauthn/authenticate/start", method: .post, body: [
            "domain": "something.blah.com",
        ])
        try XCTAssertRequest(requests[1], urlString: "https://web.stytch.com/sdk/v1/webauthn/authenticate", method: .post, body: [
            "public_key_credential": "{\"rawId\":\"ZmFrZV9pZA\",\"id\":\"ZmFrZV9pZA\",\"response\":{\"clientDataJSON\":\"ZmFrZV9qc29u\",\"signature\":\"ZmFrZV9zaWduYXR1cmU\",\"authenticatorData\":\"ZmFrZV9hdXRoX2RhdGE\",\"userHandle\":\"ZmFrZV91c2VyX2lk\"},\"type\":\"public-key\"}",
            "session_duration_minutes": 30,
        ])
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
