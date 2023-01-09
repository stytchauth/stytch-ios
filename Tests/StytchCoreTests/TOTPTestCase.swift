import XCTest
@testable import StytchCore

final class TOTPTestCase: BaseTestCase {
    var networkInterceptor: NetworkingClientInterceptor = .init()

    override func setUp() {
        super.setUp()

        Current.networkingClient = .init(handleRequest: networkInterceptor.handleRequest(request:))
        networkInterceptor.reset()
    }

    func testCreate() async throws {
        try networkInterceptor.appendSuccess(StytchClient.TOTP.CreateResponse(requestId: "", statusCode: 200, wrapped: .init(totpId: "", secret: "", qrCode: "", recoveryCodes: [], user: .mock(userId: ""), userId: "")))

        _ = try await StytchClient.totp.create(parameters: .init())

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/totps", method: .post(["expiration_minutes": 30]))
    }

    func testAuthenticate() async throws {
        try networkInterceptor.appendSuccess(AuthenticateResponse.mock)

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.totp.authenticate(parameters: .init(totpCode: "test-code"))

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/totps/authenticate", method: .post(["totp_code": "test-code", "session_duration_minutes": 30]))
    }

    func testRecover() async throws {
        try networkInterceptor.appendSuccess(StytchClient.TOTP.RecoverResponse(requestId: "", statusCode: 200, wrapped: .init(userId: "", totpId: "", user: .mock(userId: ""), session: .mock(userId: ""), sessionToken: "", sessionJwt: "")))

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.totp.recover(parameters: .init(recoveryCode: "recover-edoc"))

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/totps/recover", method: .post(["recovery_code": "recover-edoc", "session_duration_minutes": 30]))
    }

    func testRecoveryCodes() async throws {
        try networkInterceptor.appendSuccess(StytchClient.TOTP.RecoveryCodesResponse(requestId: "", statusCode: 200, wrapped: .init(userId: "", totps: [.init(lhs: .init(totpId: "", verified: false), rhs: .init(recoveryCodes: ["1234", "5678"]))])))

        _ = try await StytchClient.totp.recoveryCodes()

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/totps/recovery_codes", method: .post([:]))
    }
}

import Foundation

final class NetworkingClientInterceptor {
    var requests: [URLRequest] = []
    var responses: [Result<Data, Swift.Error>] = []

    func reset() {
        requests = []
        responses = []
    }

    func handleRequest(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)

        switch responses.removeFirst() {
        case let .success(data):
            return try (
                data,
                XCTUnwrap(.init(url: XCTUnwrap(request.url), statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:]))
            )
        case let .failure(error):
            throw error
        }
    }

    func appendSuccess(data: Data...) {
        responses.append(contentsOf: data.map { .success($0.surroundInDataJSONContainer()) })
    }

    func appendSuccess<T: Codable>(_ elements: T...) throws {
        responses.append(
            contentsOf: try elements.map {
                .success(try Current.jsonEncoder.encode(DataContainer(data: $0)))
            }
        )
    }
}

extension Data {
    func surroundInDataJSONContainer() -> Data {
        // Surround in a data json container {"data":<existing contents>}
        var result: [UInt8] = [123, 34, 100, 97, 116, 97, 34, 58, 125]
        result.insert(contentsOf: self, at: 8)
        return .init(result)
//        var bytes = Array(self)
//        bytes.insert(contentsOf: [123, 34, 100, 97, 116, 97, 34, 58], at: 0)
//        bytes.append(125)
//        return .init(bytes)
    }
}
