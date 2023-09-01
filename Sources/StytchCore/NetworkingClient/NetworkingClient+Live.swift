import Foundation

extension NetworkingClient {
    static let live: NetworkingClient = {
        #if os(iOS)
        @Dependency(\.dfpClient) var dfpClient
        @Dependency(\.captcha) var captcha
        #endif
        let session: URLSession = .init(configuration: .default)
        return .init { request, dfpEnabled, publicToken in
            #if os(iOS)
            if (dfpEnabled == true) {
                let dfpTelemetryId = try await dfpClient.getTelemetryId(publicToken)
                let captchaToken = try await captcha.executeRecaptcha()
            }
            #endif
            if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
                let (data, response) = try await session.data(for: request)
                guard let response = response as? HTTPURLResponse else { throw NetworkingClient.Error.nonHttpResponse }
                return (data, response)
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    let task = session.dataTask(with: request) { data, response, error in
                        if let error = error {
                            continuation.resume(with: .failure(error))
                            return
                        }
                        guard let data = data else {
                            continuation.resume(with: .failure(NetworkingClient.Error.missingData))
                            return
                        }
                        guard let response = response as? HTTPURLResponse else {
                            continuation.resume(with: .failure(NetworkingClient.Error.nonHttpResponse))
                            return
                        }
                        continuation.resume(with: .success((data, response)))
                    }
                    task.resume()
                }
            }
        }
    }()
}
