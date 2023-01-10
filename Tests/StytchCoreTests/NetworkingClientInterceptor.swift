import Foundation
import XCTest
@testable import StytchCore

final class NetworkingClientInterceptor {
    var requests: [URLRequest] = []
    var responses: [Result<Data, Error>] = []

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

private extension Data {
    func surroundInDataJSONContainer() -> Data {
        // Surround in a data json container {"data":<existing contents>}
        var result: [UInt8] = [123, 34, 100, 97, 116, 97, 34, 58, 125]
        result.insert(contentsOf: self, at: 8)
        return .init(result)
    }
}
