import Foundation

public extension Error {
    var stytchAPIError: StytchAPIError? {
        self as? StytchAPIError
    }

    var stytchSDKError: StytchSDKError? {
        self as? StytchSDKError
    }

    var errorInfo: String {
        if let stytchAPIError {
            return """
            ----------------------------------------------------------------------------------
            StytchAPIError
            name:           \(stytchAPIError.name)
            message:        \(stytchAPIError.message)
            statusCode:     \(stytchAPIError.statusCode)
            requestId:      \(String(describing: stytchAPIError.requestId))
            errorType:      \(stytchAPIError.errorType)
            errorMessage:   \(stytchAPIError.errorMessage)
            url:            \(String(describing: stytchAPIError.url))
            ----------------------------------------------------------------------------------
            """
        } else if let stytchSDKError {
            return """
            ----------------------------------------------------------------------------------
            StytchSDKError
            name:       \(stytchSDKError.name)
            message:    \(stytchSDKError.message)
            errorType:  \(String(describing: stytchSDKError.errorType))
            url:        \(String(describing: stytchSDKError.url))
            ----------------------------------------------------------------------------------
            """
        } else {
            return """
            ----------------------------------------------------------------------------------
            \(self)
            localizedDescription: \(localizedDescription)
            ----------------------------------------------------------------------------------
            """
        }
    }
}
