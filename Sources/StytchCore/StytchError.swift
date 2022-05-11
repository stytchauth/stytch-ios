struct StytchError: Error {
    let message: String
    let errorType: ErrorType
    let debugInfo: String?
    var localizedDescription: String { message }

    init(message: String, errorType: ErrorType = .generic, debugInfo: String? = nil) {
        self.message = message
        self.errorType = errorType
        self.debugInfo = debugInfo
    }
}

extension StytchError {
    enum ErrorType {
        case generic, network(statusCode: Int)
    }
}

extension StytchError {
    static let clientNotConfigured: Self = StytchError(
        message: "StytchClient not yet configured. `StytchClient.configure(hostUrl:publicToken:)` must be called prior to other StytchClient calls."
    )
}
