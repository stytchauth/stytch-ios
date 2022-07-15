import XCTest
@testable import StytchCore

// swiftlint:disable test_case_accessibility
class BaseTestCase: XCTestCase {
    private(set) var cookies: [HTTPCookie] = []

    private(set) var keychainItems: [String: [KeychainClient.QueryResult]] = [:]

    override func setUpWithError() throws {
        try super.setUpWithError()

        cookies = []
        keychainItems = [:]

        Current.networkingClient = .failing

        Current.cookieClient = .init(
            setCookie: { [unowned self] in self.cookies.append($0) },
            deleteCookieNamed: { [unowned self] name in self.cookies.removeAll { $0.name == name } }
        )

        Current.keychainClient = .init(
            get: { [unowned self] in self.keychainItems[$0.name] ?? [] },
            setValueForItem: { [unowned self] _, value, item in
                self.keychainItems[item.name] = [
                    .init(data: value.data, createdAt: .init(), modifiedAt: .init(), label: item.name, account: item.name, generic: nil),
                ]
            },
            removeItem: { [unowned self] item in self.keychainItems[item.name] = nil },
            resultsExistForItem: { [unowned self] item in self.keychainItems[item.name] != nil }
        )

        Current.sessionsPollingClient = .failing

        Current.timer = { _, _, _ in
            XCTFail("Unexpected timer initialization")
            return .init()
        }
        Current.asyncAfter = { _, _, _ in
            XCTFail("Unexpected asyncAfter run")
        }

        Current.sessionStorage.reset()

        Current.cryptoClient.dataWithRandomBytesOfCount = { _ in
            .init(bytes: [UInt8].mockBytes, count: [UInt8].mockBytes.count)
        }

        let defaults = MockDefaults()
        defaults.boolReturnValue = true
        Current.defaults = defaults

        StytchClient.configure(
            publicToken: "xyz",
            hostUrl: try XCTUnwrap(URL(string: "https://myapp.com"))
        )
    }
}

extension XCTest {
    func XCTAssertThrowsError<T: Sendable>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
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
}

extension Array where Element == UInt8 {
    static let mockBytes: Self = [224, 104, 60, 156, 2, 191, 85, 74, 185, 199, 49, 161, 118, 123, 201, 64, 215, 19, 33, 164, 15, 219, 234, 198, 40, 36, 231, 182, 73, 90, 135, 65]
}

extension AuthenticateResponse {
    static var mock: Self {
        let userId = "im_a_user_id"
        return .init(
            requestId: "1234",
            statusCode: 200,
            wrapped: .init(
                user: .init(
                    createdAt: Current.date(),
                    cryptoWallets: [],
                    emails: [],
                    userId: userId,
                    name: .init(firstName: "first", lastName: "last", middleName: nil),
                    phoneNumbers: [],
                    providers: [],
                    status: .active,
                    totps: [],
                    webauthnRegistrations: []
                ),
                sessionToken: "hello_session",
                sessionJwt: "jwt_for_me",
                session: .mock(userId: userId)
            )
        )
    }
}

extension Session {
    static func mock(userId: String) -> Self {
        let refDate = Date()

        return .init(
            attributes: .init(ipAddress: "", userAgent: ""),
            authenticationFactors: [
                .init(
                    deliveryMethod: .email(.init(emailId: "email_id", emailAddress: "test@stytch.com")),
                    kind: .magicLink,
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

final class MockDefaults: UserDefaults {
    var boolReturnValue: Bool = true

    override func bool(forKey _: String) -> Bool {
        boolReturnValue
    }
}
