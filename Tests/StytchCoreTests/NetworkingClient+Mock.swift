import XCTest
@testable import StytchCore

extension NetworkingClient {
    static let failing: NetworkingClient = .init { _ in
        XCTFail("Must use your own custom networking client")
        return (.init(), .init())
    }

    static func mock(
        verifyingRequest: @escaping (URLRequest) throws -> Void = { _ in },
        returning results: Result<Data, Swift.Error>...
    ) -> NetworkingClient {
        var results = results
        return .init { request in
            try verifyingRequest(request)

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

    static func success<T: Codable>(
        verifyingRequest: @escaping (URLRequest) throws -> Void = { _ in },
        _ response: T
    ) throws -> NetworkingClient {
        try .mock(
            verifyingRequest: verifyingRequest,
            returning: .success(Current.jsonEncoder.encode(DataContainer(data: response)))
        )
    }

    static func success<A: Codable, B: Codable>(
        verifyingRequest: @escaping (URLRequest) throws -> Void = { _ in },
        _ firstResponse: A,
        _ secondResponse: B
    ) throws -> NetworkingClient {
        try .mock(
            verifyingRequest: verifyingRequest,
            returning: .success(Current.jsonEncoder.encode(DataContainer(data: firstResponse))),
            .success(Current.jsonEncoder.encode(DataContainer(data: secondResponse)))
        )
    }
}
