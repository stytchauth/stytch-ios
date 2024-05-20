import Foundation

public extension Error {
    var stytchAPIError: StytchAPIError? {
        self as? StytchAPIError
    }

    var errorInfo: String {
        if let stytchAPIError {
            return "\(stytchAPIError.name) - \(stytchAPIError.message)"
        } else {
            return localizedDescription
        }
    }
}
