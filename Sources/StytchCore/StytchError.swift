public struct StytchError: Error {
    let message: String
    let debugInfo: String?

    init(message: String, debugInfo: String? = nil) {
        self.message = message
        self.debugInfo = debugInfo
    }
}
