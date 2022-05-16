import XCTest
@testable import Networking

public extension NetworkingClient {
    static let failing: NetworkingClient = .init { _, _ in
        XCTFail("Must use your own custom networking client")
        return .init(dataTask: nil)
    }

    static func mock(
        verifyingRequest: @escaping (URLRequest) -> Void = { _ in },
        returning result: Result<Data, Swift.Error>
    ) -> NetworkingClient {
        .init { request, completion in
            verifyingRequest(request)
            completion(
                // swiftlint:disable:next force_unwrapping
                result.map { ($0, .init(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])!) }
            )
            return .init(dataTask: nil)
        }
    }
}
