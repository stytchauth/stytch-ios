/// An relatively unstructured error type, most often originating from the client.
public struct StytchGenericError: Error {
    /// The message associated with the error.
    public let message: String
    /// The origin of the error.
    public let origin: Origin
    /// An optional string value which should provide additional information for debugging purposes.
    public let debugInfo: String?

    var statusCode: Int? {
        switch origin {
        case let .network(statusCode):
            return statusCode
        case .client:
            return nil
        }
    }

    init(message: String, origin: Origin = .client, debugInfo: String? = nil) {
        self.message = message
        self.origin = origin
        self.debugInfo = debugInfo
    }
}

public extension StytchGenericError {
    /// A type representing the origin of a given error.
    enum Origin {
        /// The error originated on the client.
        case client
        /// The error originated somewhere on the network, either a client or server networking error.
        case network(statusCode: Int)
    }
}

extension StytchGenericError {
    static let clientNotConfigured: Self = .init(
        message: "StytchClient not yet configured. `StytchClient.configure(hostUrl:publicToken:)` must be called prior to other StytchClient calls."
    )
}
