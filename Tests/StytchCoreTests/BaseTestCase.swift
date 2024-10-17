@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

// swiftlint:disable test_case_accessibility

class BaseTestCase: XCTestCase {
    var networkInterceptor: NetworkingClientInterceptor = .init()

    let intermediateSessionToken = "intermediateSessionToken_asdfg"

    override func setUpWithError() throws {
        try super.setUpWithError()

        Current.networkingClient = .init(handleRequest: networkInterceptor.handleRequest)
        Current.sessionsPollingClient = .failing
        Current.cookieClient = .mock()
        Current.keychainClient = .mock()
        Current.cryptoClient = .live
        Current.localStorage = .init()
        Current.timer = { _, _, _ in
            XCTFail("Unexpected timer initialization")
            return .init()
        }
        Current.asyncAfter = { _, _, _ in
            XCTFail("Unexpected asyncAfter run")
        }
        Current.sessionManager.resetSession()
        Current.cryptoClient.dataWithRandomBytesOfCount = { count in
            .init(bytes: Array([UInt8].mockBytes.prefix(Int(count))), count: Int(count))
        }

        Current.defaults = .mock()

        KeychainClient.migrations.forEach { migration in
            let migrationName = "stytch_keychain_migration_" + String(describing: migration.self)
            Current.defaults.set(true, forKey: migrationName)
        }

        StytchClient.configure(
            publicToken: "xyz",
            hostUrl: try XCTUnwrap(URL(string: "https://myapp.com"))
        )

        networkInterceptor.reset()
    }
}

extension Sequence {
    func asyncForEach(_ operation: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

extension String {
    static let mockPKCECodeVerifier: String = "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741"
    static let mockPKCECodeChallenge: String = "some code challenge"
}

extension Array where Element == UInt8 {
    static let mockBytes: Self = [224, 104, 60, 156, 2, 191, 85, 74, 185, 199, 49, 161, 118, 123, 201, 64, 215, 19, 33, 164, 15, 219, 234, 198, 40, 36, 231, 182, 73, 90, 135, 65]
}

extension User {
    static func mock(userId: ID) -> Self {
        .init(
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
        )
    }
}

extension AuthenticateResponse {
    static var mock: Self {
        let userId: User.ID = "im_a_user_id"
        return .init(
            requestId: "1234",
            statusCode: 200,
            wrapped: .init(
                user: .mock(userId: userId),
                sessionToken: "hello_session",
                sessionJwt: "jwt_for_me",
                session: .mock(userId: userId)
            )
        )
    }
}

extension Session {
    static func mock(userId: User.ID) -> Self {
        let refDate = Date()

        return .init(
            attributes: .init(ipAddress: "", userAgent: ""),
            authenticationFactors: [
                .init(
                    rawData: [
                        "type": "magic_link",
                        "last_authenticated_at": JSON(stringLiteral: ISO8601DateFormatter().string(from: refDate.addingTimeInterval(-30))),
                    ],
                    kind: "magic_link",
                    lastAuthenticatedAt: refDate.addingTimeInterval(-30)
                ),
            ],
            expiresAt: refDate.addingTimeInterval(30),
            lastAccessedAt: refDate.addingTimeInterval(-30),
            sessionId: "im_a_session_id",
            startedAt: refDate.addingTimeInterval(-30),
            userId: userId
        )
    }

    static func mockWithExpiredSession(userId: User.ID) -> Self {
        .init(
            attributes: .init(ipAddress: "", userAgent: ""),
            authenticationFactors: [
                .init(
                    rawData: [
                        "type": "magic_link",
                        "last_authenticated_at": JSON(stringLiteral: ISO8601DateFormatter().string(from: Date.distantPast)),
                    ],
                    kind: "magic_link",
                    lastAuthenticatedAt: Date.distantPast
                ),
            ],
            expiresAt: Date.distantPast,
            lastAccessedAt: Date.distantPast,
            sessionId: "im_a_session_id",
            startedAt: Date.distantPast,
            userId: userId
        )
    }
}

extension PollingClient {
    static var failing: PollingClient = .init(
        interval: 0,
        maxRetries: 0,
        queue: .main
    ) { _, _ in
        XCTFail("Shouldn't execute")
    }
}
