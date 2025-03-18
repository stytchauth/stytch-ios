import XCTest
@testable import StytchCore

final class CryptoWalletsTestCase: BaseTestCase {
    func testAuthenticateStartWithNoSession() async throws {
        networkInterceptor.responses {
            StytchClient.CryptoWallets.AuthenticateStartResponse(requestId: "mock-request-id", statusCode: 200, wrapped: .init(challenge: "mock-challenge"))
        }

        XCTAssertFalse(Current.sessionManager.hasValidSessionToken)

        _ = try await StytchClient.cryptoWallets.authenticateStart(parameters: .init(cryptoWalletType: .ethereum, cryptoWalletAddress: "mock-crypto-address"))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/crypto_wallets/authenticate/start/primary",
            method: .post([
                "crypto_wallet_type": "ethereum",
                "crypto_wallet_address": "mock-crypto-address",
            ])
        )

        XCTAssertNil(StytchClient.sessions.sessionJwt)
        XCTAssertNil(StytchClient.sessions.sessionToken)
    }

    func testAuthenticateStartWithActiveSession() async throws {
        networkInterceptor.responses {
            StytchClient.CryptoWallets.AuthenticateStartResponse(requestId: "mock-request-id", statusCode: 200, wrapped: .init(challenge: "mock-challenge"))
        }

        try Current.keychainClient.set("123", for: .sessionToken)

        XCTAssertTrue(Current.sessionManager.hasValidSessionToken)

        _ = try await StytchClient.cryptoWallets.authenticateStart(parameters: .init(cryptoWalletType: .ethereum, cryptoWalletAddress: "mock-crypto-address"))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/crypto_wallets/authenticate/start/secondary",
            method: .post([
                "crypto_wallet_type": "ethereum",
                "crypto_wallet_address": "mock-crypto-address",
            ])
        )
    }

    func testAuthenticate() async throws {
        networkInterceptor.responses { AuthenticateResponse.mock }

        XCTAssertNil(StytchClient.sessions.sessionToken)
        XCTAssertNil(StytchClient.sessions.sessionJwt)

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.cryptoWallets.authenticate(parameters: .init(cryptoWalletType: .solana, cryptoWalletAddress: "mock-crypto-address", signature: "mock-signature"))

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/crypto_wallets/authenticate",
            method: .post([
                "crypto_wallet_type": "solana",
                "crypto_wallet_address": "mock-crypto-address",
                "signature": "mock-signature",
            ])
        )

        XCTAssertEqual(StytchClient.lastAuthMethodUsed, StytchClient.ConsumerAuthMethod.crypto)
    }
}
