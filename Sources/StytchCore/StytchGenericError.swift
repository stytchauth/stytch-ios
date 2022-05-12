public struct StytchGenericError: Error {
    public let message: String
    public let origin: Origin
    public let debugInfo: String?

    init(message: String, origin: Origin = .client, debugInfo: String? = nil) {
        self.message = message
        self.origin = origin
        self.debugInfo = debugInfo
    }
}

public extension StytchGenericError {
    enum Origin {
        case client, network(statusCode: Int)
    }
}

public extension StytchGenericError {
    static let clientNotConfigured: Self = .init(
        message: "StytchClient not yet configured. `StytchClient.configure(hostUrl:publicToken:)` must be called prior to other StytchClient calls."
    )
}
