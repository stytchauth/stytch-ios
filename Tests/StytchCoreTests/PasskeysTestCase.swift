import AuthenticationServices
import XCTest
@testable import StytchCore

@available(macOS 12.0, iOS 16.0, *)
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
        XCTAssertEqual(requests[0].httpBody, Data("{\"username\":\"test@stytch.com\",\"domain\":\"something.blah.com\"}".utf8))
        XCTAssertEqual(requests[1].httpBody, Data("{\"public_key_credential\":\"{\\\"rawId\\\":\\\"ZmFrZV9pZA\\\",\\\"id\\\":\\\"ZmFrZV9pZA\\\",\\\"response\\\":{\\\"clientDataJSON\\\":\\\"ZmFrZV9qc29u\\\",\\\"attestationObject\\\":\\\"ZmFrZV9hdHRlc3RhdGlvbl9kYXRh\\\"},\\\"type\\\":\\\"public-key\\\"}\"}".utf8))
        XCTAssertEqual(requests[0].url?.absoluteString, "https://web.stytch.com/sdk/v1/webauthn/register/start")
        XCTAssertEqual(requests[1].url?.absoluteString, "https://web.stytch.com/sdk/v1/webauthn/register")
        XCTAssertTrue(requests.allSatisfy { $0.httpMethod == "POST" })
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
            if case .autoFill = requestBehavior {
                requestBehaviorIsAutoFill = true
            }
            return MockAssertion(
                rawAuthenticatorData: .init("fake_auth_data".utf8),
                userID: .init("fake_user_id".utf8),
                signature: .init("fake_signature".utf8),
                rawClientDataJSON: .init("fake_json".utf8),
                credentialID: .init("fake_id".utf8)
            )
        }
        Current.timer = { _, _, _ in .init() }
        _ = try await StytchClient.passkeys.authenticate(parameters: .init(domain: "something.blah.com", requestBehavior: .autoFill))
        XCTAssertTrue(requestBehaviorIsAutoFill)
        XCTAssertEqual(requests[0].httpBody, Data("{\"domain\":\"something.blah.com\"}".utf8))
        XCTAssertEqual(requests[1].httpBody, Data("{\"session_duration_minutes\":30,\"public_key_credential\":\"{\\\"rawId\\\":\\\"ZmFrZV9pZA\\\",\\\"id\\\":\\\"ZmFrZV9pZA\\\",\\\"response\\\":{\\\"clientDataJSON\\\":\\\"ZmFrZV9qc29u\\\",\\\"signature\\\":\\\"ZmFrZV9zaWduYXR1cmU\\\",\\\"authenticatorData\\\":\\\"ZmFrZV9hdXRoX2RhdGE\\\",\\\"userHandle\\\":\\\"ZmFrZV91c2VyX2lk\\\"},\\\"type\\\":\\\"public-key\\\"}\"}".utf8))
        XCTAssertEqual(requests[0].url?.absoluteString, "https://web.stytch.com/sdk/v1/webauthn/authenticate/start")
        XCTAssertEqual(requests[1].url?.absoluteString, "https://web.stytch.com/sdk/v1/webauthn/authenticate")
        XCTAssertTrue(requests.allSatisfy { $0.httpMethod == "POST" })
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
