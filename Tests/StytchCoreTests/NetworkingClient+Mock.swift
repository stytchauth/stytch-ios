import XCTest
@testable import StytchCore

extension NetworkingClient {
    static let failing: NetworkingClient = .init { _ in
        XCTFail("Must use your own custom networking client")
        return (.init(), .init())
    }

    static func mock(
        verifyingRequest: @escaping (URLRequest) -> Void = { _ in },
        returning results: Result<Data, Swift.Error>...
    ) -> NetworkingClient {
        var results = results
        return .init { request in
            verifyingRequest(request)

            switch results.removeFirst() {
            case let .success(data):
                return try (
                    data,
                    XCTUnwrap(.init(url: XCTUnwrap(request.url), statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:]))
                )
            case let .failure(error):
                throw error
            }
        }
    }
}
