import Foundation

extension NetworkingClient {
    static let live: NetworkingClient = {
        #if os(iOS)
        @Dependency(\.dfpClient) var dfpClient
        @Dependency(\.captcha) var captcha
        #endif
        let session: URLSession = .init(configuration: .default)
        return .init { request, dfpEnabled, publicToken in
            var newRequest: URLRequest = request
            #if os(iOS)
            if dfpEnabled == true {
                let oldBody = newRequest.httpBody ?? Data()
                var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
                newBody["dfp_telemetry_id"] = try await dfpClient.getTelemetryId(publicToken) as AnyObject
                let bodyWithDfp = try JSONSerialization.data(withJSONObject: newBody)
                newRequest.httpBody = bodyWithDfp
            }
            #endif
            if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
                let (data, response) = try await session.data(for: newRequest)
                guard let response = response as? HTTPURLResponse else { throw NetworkingClient.Error.nonHttpResponse }
                #if os(iOS)
                if dfpEnabled == true, response.statusCode == 403 {
                    let oldBody = newRequest.httpBody ?? Data()
                    var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
                    newBody["dfp_telemetry_id"] = try await dfpClient.getTelemetryId(publicToken) as AnyObject
                    newBody["captcha_token"] = try await captcha.executeRecaptcha() as AnyObject
                    let bodyWithDfp = try JSONSerialization.data(withJSONObject: newBody)
                    newRequest.httpBody = bodyWithDfp
                    let (captchaData, captchaResponse) = try await session.data(for: newRequest)
                    guard let captchaResponse = captchaResponse as? HTTPURLResponse else { throw NetworkingClient.Error.nonHttpResponse }
                    return (data, response)
                }
                #endif
                return (data, response)
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    let task = session.dataTask(with: newRequest) { data, response, error in
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
                        #if os(iOS)
                        if dfpEnabled == true, response.statusCode == 403 {
                            Task {
                                var captchaRequest = newRequest
                                let oldBody = captchaRequest.httpBody ?? Data()
                                var newBody = try JSONSerialization.jsonObject(with: oldBody) as? [String: AnyObject] ?? [:]
                                newBody["dfp_telemetry_id"] = try await dfpClient.getTelemetryId(publicToken) as AnyObject
                                newBody["captcha_token"] = try await captcha.executeRecaptcha() as AnyObject
                                let bodyWithDfp = try JSONSerialization.data(withJSONObject: newBody)
                                captchaRequest.httpBody = bodyWithDfp
                                session.dataTask(with: captchaRequest) { data, response, error in
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
                                .resume()
                            }
                            return
                        }
                        #endif
                        continuation.resume(with: .success((data, response)))
                    }
                    task.resume()
                }
            }
        }
    }()
}
