import CryptoKit
import XCTest
@testable import StytchCore

#if !os(tvOS) && !os(watchOS)
final class BiometricsTestCase: BaseTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        LocalAuthenticationContextManager.setLocalAuthenticationContext(context: MockLocalAuthenticationContext())
    }

    func testRegistration() async throws {
        XCTAssertFalse(StytchClient.biometrics.registrationAvailable)

        let sessionToken = "session_token_123"
        let regId: User.BiometricRegistration.ID = "bio_reg_123"
        let userId: User.ID = "user_123"
        let email = "example@stytch.com"

        try Current.userDefaultsClient.setStringValue(sessionToken, for: .sessionToken)

        let registerStartResponse = try StytchClient.Biometrics.RegisterStartResponse(
            biometricRegistrationId: regId,
            challenge: Current.cryptoClient.dataWithRandomBytesOfCount(32)
        )
        networkInterceptor.responses {
            registerStartResponse
            Response<StytchClient.Biometrics.RegisterCompleteResponseData>(
                requestId: "req_123",
                statusCode: 200,
                wrapped: .init(
                    biometricRegistrationId: regId,
                    user: .mock(userId: userId),
                    session: .mock(userId: userId),
                    sessionToken: sessionToken,
                    sessionJwt: "session_jwt",
                    userDevice: nil
                )
            )
        }

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.biometrics.register(parameters: .init(identifier: email))

        XCTAssertTrue(StytchClient.biometrics.registrationAvailable)
        XCTAssertEqual(try Current.keychainClient.getQueryResults(item: .privateKeyRegistration).first?.label, email)
    }

    func testAuthenticate() async throws {
        XCTAssertFalse(StytchClient.biometrics.registrationAvailable)

        let regId: User.BiometricRegistration.ID = "bio_reg_123"
        let userId: User.ID = "user_123"
        let email = "example@stytch.com"
        let privateKey = Curve25519.Signing.PrivateKey()
        let challenge = try Current.cryptoClient.dataWithRandomBytesOfCount(32)

        Current.cryptoClient.signChallengeWithPrivateKey = { challenge, _ in
            .init((0..<challenge.count).map { UInt8($0) })
        }

        // Set the .privateKeyRegistration
        try Current.keychainClient.setPrivateKeyRegistration(
            key: privateKey.rawRepresentation,
            registration: .init(userId: userId, userLabel: email, registrationId: regId),
            accessPolicy: .deviceOwnerAuthenticationWithBiometrics
        )

        // Set the .biometricKeyRegistration
        try Current.userDefaultsClient.setStringValue(regId.rawValue, for: .biometricKeyRegistration)

        XCTAssertTrue(StytchClient.biometrics.registrationAvailable)

        networkInterceptor.responses {
            StytchClient.Biometrics.AuthenticateStartResponse(challenge: challenge, biometricRegistrationId: regId)
            AuthenticateResponse(
                requestId: "req_123",
                statusCode: 200,
                wrapped: .init(
                    user: .mock(userId: userId),
                    sessionToken: "session_token_123",
                    sessionJwt: "session_jwt_123",
                    session: .mock(userId: userId),
                    userDevice: nil
                )
            )
        }

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.biometrics.authenticate(parameters: .init())

        let data = try XCTUnwrap(networkInterceptor.requests[1].httpBody)
        let parameters = try Current.jsonDecoder.decode(StytchClient.Biometrics.AuthenticateCompleteParameters.self, from: data)
        XCTAssertEqual(
            parameters.signature,
            try Current.cryptoClient.signChallengeWithPrivateKey(challenge, privateKey.rawRepresentation)
        )

        XCTAssertEqual(StytchClient.lastAuthMethodUsed, StytchClient.ConsumerAuthMethod.biometrics)
    }

    func testRegistrationRemoval() async throws {
        XCTAssertFalse(StytchClient.biometrics.registrationAvailable)

        let regId: User.BiometricRegistration.ID = "bio_reg_123"
        let userId: User.ID = "user_123"
        let email = "example@stytch.com"
        let privateKey = Curve25519.Signing.PrivateKey()

        Current.cryptoClient.signChallengeWithPrivateKey = { challenge, _ in
            .init((0..<challenge.count).map { UInt8($0) })
        }

        // Set the .privateKeyRegistration
        try Current.keychainClient.setPrivateKeyRegistration(
            key: privateKey.rawRepresentation,
            registration: .init(userId: userId, userLabel: email, registrationId: regId),
            accessPolicy: .deviceOwnerAuthenticationWithBiometrics
        )

        // Set the .biometricKeyRegistration
        try Current.userDefaultsClient.setStringValue(regId.rawValue, for: .biometricKeyRegistration)

        XCTAssertTrue(StytchClient.biometrics.registrationAvailable)

        networkInterceptor.responses {
            StytchClient.UserManagement.UserResponseData(
                user: .mock(userId: "user_63823")
            )
        }

        _ = try await StytchClient.biometrics.removeRegistration()

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/users/biometric_registrations/bio_reg_123", method: .delete)
        XCTAssertFalse(StytchClient.biometrics.registrationAvailable)
    }

    func testRegisterThrowsErrorWhenPrivateKeyExists() async throws {
        try Current.userDefaultsClient.setStringValue("session_token_123", for: .sessionToken)

        // Set the .privateKeyRegistration
        try Current.keychainClient.setPrivateKeyRegistration(
            key: Curve25519.Signing.PrivateKey().rawRepresentation,
            registration: .init(userId: "user_123", userLabel: "example@stytch.com", registrationId: "bio_reg_123"),
            accessPolicy: .deviceOwnerAuthenticationWithBiometrics
        )
        XCTAssertTrue(StytchClient.biometrics.registrationAvailable)

        await XCTAssertThrowsErrorAsync(
            _ = try await StytchClient.biometrics.register(parameters: .init(identifier: "example@stytch.com")),
            StytchSDKError.biometricsAlreadyEnrolled
        )
    }
}
#endif
