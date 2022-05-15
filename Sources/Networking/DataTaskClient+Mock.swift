import Foundation

#if DEBUG
public extension DataTaskClient {
    // swiftlint:disable force_unwrapping
    static func mock(returning result: Result<Data, Error>, verifyingRequest: @escaping (URLRequest) -> Void = { _ in }) -> DataTaskClient {
        .init { request, _, completion in
            verifyingRequest(request)
            completion(
                result.map { ($0, .init(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: request.allHTTPHeaderFields)!) }
            )
            return .init(dataTask: nil)
        }
    }
    // swiftlint:enable force_unwrapping
}
#endif
