import Networking
import XCTest
@testable import StytchCore

// swiftlint:disable test_case_accessibility
class BaseTestCase: XCTestCase {
    private(set) var cookies: [HTTPCookie] = []

    private(set) var keychainItems: [String: String] = [:]

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
            getItem: { [unowned self] in self.keychainItems[$0.name] },
            setValueForItem: { [unowned self] _, value, item in self.keychainItems[item.name] = value },
            removeItem: { [unowned self] _, item in self.keychainItems[item.name] = nil },
            resultExists: { [unowned self] item in self.keychainItems[item.name] != nil }
        )

        Current.sessionStorage.reset()

        Current.uuid = { UUID.mock }

        StytchClient.configure(
            publicToken: "xyz",
            hostUrl: try XCTUnwrap(URL(string: "https://myapp.com"))
        )
    }
}

extension Sequence {
    func asyncForEach(_ operation: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

extension AuthenticateResponse {
    static var mock: Self {
        .init(
            requestId: "1234",
            statusCode: 200,
            wrapped: .init(
                user: nil,
                sessionToken: "hello_session",
                sessionJwt: "jwt_for_me",
                session: .mock(userId: "im_a_user_id")
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
