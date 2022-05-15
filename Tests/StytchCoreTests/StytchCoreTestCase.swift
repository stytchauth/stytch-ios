import XCTest
@testable import StytchCore

final class StytchCoreTestCase: XCTestCase {
    private var mockAuthenticateResponse: AuthenticateResponse {
        let refDate = Date()
        let userId = "im_a_user_id"

        return .init(
            requestId: "1234",
            statusCode: 200,
            wrapped: .init(
                user: nil,
                sessionToken: "hello_session",
                sessionJwt: "jwt_for_me",
                session: .init(
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
            )
        )
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        StytchClient.configure(
            publicToken: "xyz",
            hostUrl: try XCTUnwrap(URL(string: "https://myapp.com"))
        )
    }

    @available(iOS 13.0, *)
    func testMagicLinksEmailLoginOrCreate() async throws {
        let container = DataContainer(data: BasicResponse(requestId: "1234", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        Current.networkingClient = .init(
            dataTaskClient: .mock(returning: .success(data))
        )
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
    }

    @available(iOS 13.0, *)
    func testMagicLinksAuthenticate() async throws {
        let authResponse = mockAuthenticateResponse
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        Current.networkingClient = .init(
            dataTaskClient: .mock(returning: .success(data))
        )
        let parameters: StytchClient.MagicLinks.AuthenticateParameters = .init(
            token: "12345",
            sessionDuration: 15
        )

        let response = try await StytchClient.magicLinks.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.userId, mockAuthenticateResponse.userId)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .nanosecond))
    }

    @available(iOS 13.0, *)
    func testHandleUrl() async throws {
        let authResponse = mockAuthenticateResponse
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
}
