import Networking
import XCTest
@testable import StytchCore

final class StytchCoreTestCase: XCTestCase {
    private var cookies: [HTTPCookie] = []

    private var keychainItems: [String: String] = [:]

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

        StytchClient.configure(
            publicToken: "xyz",
            hostUrl: try XCTUnwrap(URL(string: "https://myapp.com"))
        )
    }

    @available(iOS 13.0, *)
    func testMagicLinksEmailLoginOrCreate() async throws {
        let container = DataContainer(data: BasicResponse(requestId: "1234", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .init(dataTaskClient: .mock(returning: .success(data)) { request = $0 })
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "asdf@stytch.com",
            loginMagicLinkUrl: baseUrl.appendingPathComponent("login"),
            signupMagicLinkUrl: baseUrl.appendingPathComponent("signup"),
            loginExpiration: 30,
            signupExpiration: 30
        )

        let response = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/magic_links/email/login_or_create")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"email\":\"asdf@stytch.com\",\"signup_magic_link_url\":\"https:\\/\\/myapp.com\\/signup\",\"login_magic_link_url\":\"https:\\/\\/myapp.com\\/login\",\"login_expiration_minutes\":30,\"signup_expiration_minutes\":30}".utf8))
    }

    @available(iOS 13.0, *)
    func testMagicLinksAuthenticate() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .init(dataTaskClient: .mock(returning: .success(data)) { request = $0 })
        let parameters: StytchClient.MagicLinks.AuthenticateParameters = .init(
            token: "12345",
            sessionDuration: 15
        )

        let response = try await StytchClient.magicLinks.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.userId, authResponse.userId)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .nanosecond))

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/magic_links/authenticate")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"token\":\"12345\",\"session_duration_minutes\":15}".utf8))
    }

    @available(iOS 13.0, *)
    func testSessionsAuthenticate() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .init(dataTaskClient: .mock(returning: .success(data)) { request = $0 })

        let parameters: StytchClient.Sessions.AuthenticateParameters = .init(duration: 15)

        let unauthenticatedResult = try await StytchClient.sessions.authenticate(parameters: parameters)

        guard case .unauthenticated = unauthenticatedResult else {
            XCTFail("Expected to be unauthenticated")
            return
        }

        Current.sessionStorage.updateSession(
            .mock(userId: "i_am_user"),
            tokens: [.jwt("i'm_jwt"), .opaque("opaque_all_day")],
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        let authenticatedResult = try await StytchClient.sessions.authenticate(parameters: parameters)

        guard case let .authenticated(response) = authenticatedResult else {
            XCTFail("Expected authenticated")
            return
        }
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.userId, authResponse.userId)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .nanosecond))

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/sessions/authenticate")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"session_duration_minutes\":15,\"session_token\":\"opaque_all_day\"}".utf8))

        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))
        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
    }

    @available(iOS 13.0, *)
    func testSessionsRevoke() async throws {
        let container: DataContainer<BasicResponse> = .init(data: .init(requestId: "request_id", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .init(dataTaskClient: .mock(returning: .success(data)) { request = $0 })

        let unauthenticatedResult = try await StytchClient.sessions.revoke()

        guard case .unauthenticated = unauthenticatedResult else {
            XCTFail("Expected to be unauthenticated")
            return
        }

        Current.sessionStorage.updateSession(
            .mock(userId: "i_am_user"),
            tokens: [.jwt("i'm_jwt"), .opaque("opaque_all_day")],
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("opaque_all_day"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("i'm_jwt"))

        let authenticatedResult = try await StytchClient.sessions.revoke()

        guard case let .authenticated(response) = authenticatedResult else {
            XCTFail("Expected authenticated")
            return
        }
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "request_id")

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/sessions/revoke")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"session_token\":\"opaque_all_day\"}".utf8))

        XCTAssertNil(StytchClient.sessions.sessionJwt)
        XCTAssertNil(StytchClient.sessions.sessionToken)
    }

    @available(iOS 13.0, *)
    func testOtpLoginOrCreate() async throws {
        let container: DataContainer<StytchClient.OneTimePasscodes.LoginOrCreateResponse> = .init(
            data: .init(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(methodId: "method_id_1234")
            )
        )
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .init(dataTaskClient: .mock(returning: .success(data)) { request = $0 })

        try await [
            (
                StytchClient.OneTimePasscodes.LoginOrCreateParameters(deliveryMethod: .whatsapp(phoneNumber: "+12345678901"), expiration: 3),
                "https://web.stytch.com/sdk/v1/otps/whatsapp/login_or_create",
                "{\"expiration_minutes\":3,\"phone_number\":\"+12345678901\"}"
            ),
            (
                .init(deliveryMethod: .sms(phoneNumber: "+11098765432")),
                "https://web.stytch.com/sdk/v1/otps/sms/login_or_create",
                "{\"expiration_minutes\":2,\"phone_number\":\"+11098765432\"}"
            ),
            (
                .init(deliveryMethod: .email("test@stytch.com")),
                "https://web.stytch.com/sdk/v1/otps/email/login_or_create",
                "{\"expiration_minutes\":2,\"email\":\"test@stytch.com\"}"
            )
        ].asyncForEach { params, urlString, body in
            let response = try await StytchClient.otps.loginOrCreate(parameters: params)
            XCTAssertEqual(response.methodId, "method_id_1234")
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(response.requestId, "1234")

            // Verify request
            XCTAssertEqual(request?.url?.absoluteString, urlString)
            XCTAssertEqual(request?.httpMethod, "POST")
            XCTAssertEqual(request?.httpBody, Data(body.utf8))

            XCTAssertNil(StytchClient.sessions.sessionJwt)
            XCTAssertNil(StytchClient.sessions.sessionToken)
        }
    }

    @available(iOS 13.0, *)
    func testOtpAuthenticate() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .init(dataTaskClient: .mock(returning: .success(data)) { request = $0 })
        let parameters: StytchClient.OneTimePasscodes.AuthenticateParameters = .init(
            code: "i_am_code",
            methodId: "method_id_fake_id",
            sessionDuration: 20
        )

        XCTAssertNil(StytchClient.sessions.sessionToken)
        XCTAssertNil(StytchClient.sessions.sessionJwt)

        let response = try await StytchClient.otps.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.userId, authResponse.userId)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .nanosecond))

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/otps/authenticate")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"token\":\"i_am_code\",\"method_id\":\"method_id_fake_id\",\"session_duration_minutes\":20}".utf8))
    }


    @available(iOS 13.0, *)
    func testHandleUrl() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        Current.networkingClient = .init(
            dataTaskClient: .mock(returning: .success(data))
        )

        let notHandledUrl = try XCTUnwrap(URL(string: "https://myapp.com?token=12345"))

        switch try await StytchClient.handle(url: notHandledUrl, sessionDuration: 30) {
        case .handled:
            XCTFail("expected to be nothandled")
        case let .notHandled(url):
            XCTAssertEqual(url, notHandledUrl)
        }

        let handledUrl = try XCTUnwrap(URL(string: "https://myapp.com?token=12345&stytch_token_type=magic_links"))

        switch try await StytchClient.handle(url: handledUrl, sessionDuration: 30) {
        case let .handled((response, _)):
            XCTAssertEqual(response.sessionJwt, "jwt_for_me")
            XCTAssertEqual(response.session.authenticationFactors.count, 1)
        case .notHandled:
            XCTFail("expected to be handled")
        }
    }

    func testPath() {
        let path = Endpoint.Path(rawValue: "path")
        XCTAssertEqual(path.rawValue, "path")
        XCTAssertEqual(path.appendingPathComponent("").rawValue, "path")
        XCTAssertEqual(path.appendingPathComponent("new_path").rawValue, "path/new_path")
        XCTAssertEqual(
            path.appendingPathComponent("new_path").appendingPathComponent("other_path").rawValue,
            "path/new_path/other_path"
        )
    }

    func testEndpoint() throws {
        let url = try XCTUnwrap(URL(string: "https://stytch.com/path/component"))
        XCTAssertEqual(url.path, "/path/component")
        let endpoint = Endpoint(path: "/other/path")
        XCTAssertEqual(endpoint.url(baseUrl: url).path, "/path/component/other/path")
    }

    func testLossyArray() throws {
        struct Test: Decodable {
            let stringDigit: String
        }
        let decoder = JSONDecoder()
        do {
            let json = "[{\"stringDigit\":\"one\"},{\"stringDigit\":2},{\"stringDigit\":\"three\"}]"
            let testArray = try decoder.decode(LossyArray<Test>.self, from: Data(json.utf8))
            XCTAssertEqual(testArray.wrappedValue.count, 2)
            XCTAssertEqual(testArray.wrappedValue[0].stringDigit, "one")
            XCTAssertEqual(testArray.wrappedValue[1].stringDigit, "three")
        }
        do {
            let json = "[{\"stringDigit\":\"one\"},{\"stringDigit\":\"two\"},{\"stringDigit\":\"three\"}]"
            let testArray = try decoder.decode(LossyArray<Test>.self, from: Data(json.utf8))
            XCTAssertEqual(testArray.wrappedValue.count, 3)
            XCTAssertEqual(testArray.wrappedValue[0].stringDigit, "one")
            XCTAssertEqual(testArray.wrappedValue[1].stringDigit, "two")
            XCTAssertEqual(testArray.wrappedValue[2].stringDigit, "three")
        }
    }

    func testStringExtensions() {
        XCTAssertEqual("blah-blah-bloop".base64Encoded, "YmxhaC1ibGFoLWJsb29w")
        XCTAssertEqual("blah-blah-bloop".dropLast { $0 != "-" }, "blah-blah-")
    }

    func testURLComponentsIsLocalHost() throws {
        func testIsLocalHost(urlString: String, expectation: Bool, line: UInt = #line) throws {
            let urlComponents = try XCTUnwrap(URLComponents(string: urlString))
            XCTAssertEqual(urlComponents.isLocalHost, expectation, line: line)
        }

        try [
            ("http://127.0.0.1/my-path", true),
            ("http://localhost:8080/my-path", true),
            ("http://[::1]/my-path", true),
            ("https://my-domain.com/my-path", false),
        ].forEach { urlString, expectation in
            try testIsLocalHost(urlString: urlString, expectation: expectation)
        }
    }

    func testKeychainClient() throws {
        let item: KeychainClient.Item = .init(kind: .token, name: "item")
        let otherItem: KeychainClient.Item = .init(kind: .token, name: "other_item")

        XCTAssertNil(try Current.keychainClient.get(item))
        XCTAssertNil(try Current.keychainClient.get(otherItem))

        try Current.keychainClient.set("test test", for: item)

        XCTAssertTrue(Current.keychainClient.resultExists(for: item))
        XCTAssertFalse(Current.keychainClient.resultExists(for: otherItem))

        XCTAssertEqual(try Current.keychainClient.get(item), "test test")

        try Current.keychainClient.set("test again", for: item)

        XCTAssertEqual(try Current.keychainClient.get(item), "test again")

        try Current.keychainClient.remove(item)

        XCTAssertFalse(Current.keychainClient.resultExists(for: item))
        XCTAssertFalse(Current.keychainClient.resultExists(for: otherItem))
    }

    func testKeychainItem() {
        let item: KeychainClient.Item = .init(kind: .token, name: "item")

        XCTAssertEqual(
            item.getQuery,
            ["acct": "item", "class": "genp", "m_Limit": "m_LimitOne", "r_Data": 1, "nleg": 1] as CFDictionary
        )
        XCTAssertEqual(
            item.querySegmentForUpdate(for: "value") as CFDictionary,
            ["v_Data": Data("value".utf8)] as CFDictionary
        )
        XCTAssertEqual(
            item.insertQuery(value: "new_value") as CFDictionary,
            ["acct": "item", "class": "genp", "v_Data": Data("new_value".utf8), "nleg": 1] as CFDictionary
        )
    }

    func testCookieClient() throws {
        XCTAssertTrue(cookies.isEmpty)

        Current.cookieClient.set(
            cookie: try XCTUnwrap(HTTPCookie(properties: [.name: "cookie", .value: "test", .domain: "domain.com", .path: "/"]))
        )

        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(try XCTUnwrap(cookies.last).name, "cookie")

        Current.cookieClient.deleteCookie(named: "other_name")

        XCTAssertFalse(cookies.isEmpty)

        Current.cookieClient.set(
            cookie: try XCTUnwrap(HTTPCookie(properties: [.name: "other_name", .value: "test", .domain: "domain.com", .path: "/"]))
        )

        XCTAssertEqual(cookies.count, 2)

        Current.cookieClient.deleteCookie(named: "cookie")

        XCTAssertEqual(cookies.count, 1)

        XCTAssertEqual(try XCTUnwrap(cookies.last).name, "other_name")

        Current.cookieClient.deleteCookie(named: "other_name")

        XCTAssertTrue(cookies.isEmpty)
    }
}

private extension AuthenticateResponse {
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

private extension Session {
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

private extension NetworkingClient {
    static let failing: NetworkingClient = .init(
        dataTaskClient: .init { _, _, _ in
            XCTFail("Must use your own custom networking client")
            return .init(dataTask: nil)
        }
    )
}

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
