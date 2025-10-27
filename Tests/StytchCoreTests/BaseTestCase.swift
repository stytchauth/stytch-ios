@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

// swiftlint:disable test_case_accessibility

class BaseTestCase: XCTestCase {
    var networkInterceptor: NetworkingClientInterceptor = .init()

    let intermediateSessionToken = "intermediateSessionToken_asdfg"

    override func setUpWithError() throws {
        try super.setUpWithError()

        Current.networkingClient = networkInterceptor
        Current.sessionsPollingClient = .failing
        Current.keychainClient = KeychainClientMock()
        Current.userDefaultsClient = EncryptedUserDefaultsClientMock()
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

        Current.keychainClient.migrations().forEach { migration in
            let migrationName = "stytch_keychain_migration_" + String(describing: migration.self)
            Current.defaults.set(true, forKey: migrationName)
        }

        StytchClient.configure(configuration: .init(
            publicToken: "xyz",
            defaultSessionDuration: 5,
            hostUrl: try XCTUnwrap(URL(string: "https://myapp.com"))
        ))

        networkInterceptor.reset()

        Current.sessionManager.consumerLastAuthMethodUsed = StytchClient.ConsumerAuthMethod.unknown
        Current.sessionManager.b2bLastAuthMethodUsed = StytchB2BClient.B2BAuthMethod.unknown
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
                session: .mock(userId: userId),
                userDevice: nil
            )
        )
    }
}

extension Session {
    static func mock(userId: User.ID, sessionId: Session.ID = "im_a_session_id") -> Self {
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
            sessionId: sessionId,
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

extension XCTestCase {
    func assertURLContainsParameters(_ url: URL, expectedParameters: [String: String], file: StaticString = #file, line: UInt = #line) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else {
            XCTFail("Invalid URL or missing query parameters", file: file, line: line)
            return
        }

        let queryDictionary = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value ?? "") })

        for (key, expectedValue) in expectedParameters {
            XCTAssertEqual(queryDictionary[key], expectedValue, "URL missing expected query parameter: \(key)", file: file, line: line)
        }
    }
}

#if !os(tvOS) && !os(watchOS)
import LocalAuthentication
class MockLocalAuthenticationContext: LAContextEvaluating {
    var canEvaluate = true
    var shouldSucceed = true
    var thrownError: Error?

    var biometryType: LABiometryType {
        .faceID
    }

    func canEvaluatePolicy(_: LAPolicy, error _: NSErrorPointer) -> Bool {
        canEvaluate
    }

    func evaluatePolicy(_: LAPolicy, localizedReason _: String) async throws -> Bool {
        if let error = thrownError {
            throw error
        }
        return shouldSucceed
    }
}
#endif
