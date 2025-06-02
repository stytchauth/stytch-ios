import Foundation

/// Base class representing an error within the Stytch ecosystem.
public class StytchError: Error, Equatable {
    public var name: String
    public var message: String

    init(
        name: String,
        message: String
    ) {
        self.name = name
        self.message = message
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.message == rhs.message
    }
}

/// Error class representing when the Stytch SDK cannot reach the Stytch API.
public class StytchAPIUnreachableError: StytchError {
    init(message: String) {
        super.init(name: "StytchAPIUnreachableError", message: message)
    }
}

/// Error class representing a schema error within the Stytch API.
public class StytchAPISchemaError: StytchError {
    init(message: String) {
        super.init(name: "StytchAPISchemaError", message: message)
    }
}

/// Error class representing invalid input within the Stytch SDK.
public class StytchSDKUsageError: StytchError {
    init(message: String) {
        super.init(name: "StytchSDKUsageError", message: message)
    }
}
