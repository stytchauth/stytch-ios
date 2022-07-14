import XCTest
@testable import StytchCore

extension NetworkingClient {
    static let failing: NetworkingClient = .init { _ in
        XCTFail("Must use your own custom networking client")
        return (.init(), .init())
    }

    static func mock(
        verifyingRequest: @escaping (URLRequest) -> Void = { _ in },
        returning result: Result<Data, Swift.Error>...
    ) -> NetworkingClient {
        var copy = result
        return .init { request in
            verifyingRequest(request)

            switch copy.removeFirst() {
            case let .success(data):
                return (data, .init(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])!)
            case let .failure(error):
                throw error
            }
        }
    }
}
