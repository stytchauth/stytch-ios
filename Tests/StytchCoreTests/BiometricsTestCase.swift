@testable import StytchCore
import CryptoKit
import XCTest

final class BiometricsTestCase: BaseTestCase {
    func testRegistration() async throws {
        XCTAssertFalse(StytchClient.biometrics.registrationAvailable)

        let sessionToken = "session_token_123"
        let regId = "bio_reg_123"
        let userId = "user_123"
        let email = "example@stytch.com"

        try Current.keychainClient.set(sessionToken, for: .sessionToken)

        Current.networkingClient = try .success(
            StytchClient.Biometrics.RegisterStartResponse(
                biometricRegistrationId: regId,
                challenge: Current.cryptoClient.dataWithRandomBytesOfCount(32)
            ),
            Response<StytchClient.Biometrics.RegisterCompleteResponseData>(
                requestId: "req_123",
                statusCode: 200,
                wrapped: .init(
                    biometricRegistrationId: regId,
                    user: .mock(userId: userId),
                    session: .mock(userId: userId),
                    sessionToken: sessionToken,
                    sessionJwt: "session_jwt"
                )
            )
        )

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.biometrics.register(parameters: .init(identifier: email))

        XCTAssertTrue(StytchClient.biometrics.registrationAvailable)

        let registration = try XCTUnwrap(Current.keychainClient.get(.privateKeyRegistration).first)

        XCTAssertEqual(registration.label, email)
    }

    func testAuthenticate() async throws {
        XCTAssertFalse(StytchClient.biometrics.registrationAvailable)

        let regId = "bio_reg_123"
        let userId = "user_123"
        let email = "example@stytch.com"
        let privateKey = Curve25519.Signing.PrivateKey()
        let challenge = try Current.cryptoClient.dataWithRandomBytesOfCount(32)

        Current.cryptoClient.signChallengeWithPrivateKey = { challenge, _ in
            .init((0..<challenge.count).map { UInt8($0) })
        }

        try Current.keychainClient.set(
            key: privateKey.rawRepresentation,
            registration: .init(userId: userId, userLabel: email, registrationId: regId),
            accessPolicy: .deviceOwnerAuthenticationWithBiometrics
        )

        Current.defaults.set(true, forKey: "biometric_registration_available")

        XCTAssertTrue(StytchClient.biometrics.registrationAvailable)

        Current.networkingClient = try .success(
            verifyingRequest: { request in
                guard request.url?.path == "/sdk/v1/biometrics/authenticate" else { return }
                let data = try XCTUnwrap(request.httpBody)
                let parameters = try Current.jsonDecoder.decode(StytchClient.Biometrics.AuthenticateCompleteParameters.self, from: data)
                XCTAssertEqual(
                    parameters.signature,
                    try Current.cryptoClient.signChallengeWithPrivateKey(challenge, privateKey.rawRepresentation)
                )
            },
            StytchClient.Biometrics.AuthenticateStartResponse(challenge: challenge, biometricRegistrationId: regId),
            AuthenticateResponse(
                requestId: "req_123",
                statusCode: 200,
                wrapped: .init(user: .mock(userId: userId), sessionToken: "session_token_123", sessionJwt: "session_jwt_123", session: .mock(userId: userId))
            )
        )

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.biometrics.authenticate(parameters: .init())
    }
}

extension NetworkingClient {
    static func success<T: Codable>(
        verifyingRequest: @escaping (URLRequest) throws -> Void = { _ in },
        _ response: T
    ) throws -> NetworkingClient {
        try .mock(
            verifyingRequest: verifyingRequest,
            returning: .success(Current.jsonEncoder.encode(DataContainer(data: response)))
        )
    }

    static func success<A: Codable, B: Codable>(
        verifyingRequest: @escaping (URLRequest) throws -> Void = { _ in },
        _ firstResponse: A,
        _ secondResponse: B
    ) throws -> NetworkingClient {
        try .mock(
            verifyingRequest: verifyingRequest,
            returning: .success(Current.jsonEncoder.encode(DataContainer(data: firstResponse))),
            .success(Current.jsonEncoder.encode(DataContainer(data: secondResponse)))
        )
    }
}
