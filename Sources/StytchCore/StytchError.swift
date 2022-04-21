struct StytchError: Error {
    let message: String
    let debugInfo: String?
    var localizedDescription: String { message }

    init(message: String, debugInfo: String? = nil) {
        self.message = message
        self.debugInfo = debugInfo
    }
}

extension StytchError {
    static let clientNotConfigured: Self = StytchError(
        message: "StytchClient not yet configured. `StytchClient.configure(hostUrl:publicToken:)` must be called prior to other StytchClient calls."
    )
}
