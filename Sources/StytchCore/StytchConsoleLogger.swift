import Foundation
import os.log

@objc
public final class StytchConsoleLogger: NSObject {
    // Create a logger with subsystem and category for filtering in Console
    // In Console.app you can filter using:
    //   subsystem:com.stytch.sdk
    //   category:console
    // You can also combine filters, for example:
    //   subsystem:com.stytch.sdk level:error
    private static let logger = Logger(subsystem: "com.stytch.sdk", category: "console")
}

// These map directly to OSLogType levels and are easy to call.
// Note: error and warning messages always appear in Console by default.
// Info messages do NOT appear unless you enable "Action->Include Info Messages" in Console
// or change log settings via `log config` in Terminal. This is an Apple logging behavior
// designed to reduce noise, not a limitation of this class.
public extension StytchConsoleLogger {
    /// Log an informational message
    @objc static func log(message: String) {
        logger.info("\(message, privacy: .public)")
    }

    /// Log a warning message
    @objc static func warn(message: String) {
        logger.warning("\(message, privacy: .public)")
    }

    /// Log an error message
    @objc static func error(message: String) {
        logger.error("\(message, privacy: .public)")
    }
}

// Use this if you want one entry point with a configurable log level.
// Callers pass in an OSLogType (.debug, .info, .error, etc).
// Example:
//   StytchConsoleLogger.log(message: "debugging", type: .debug)
//   StytchConsoleLogger.log(message: "problem!", type: .error)
public extension StytchConsoleLogger {
    /// Log a message with a custom log level
    @objc static func log(message: String, type: OSLogType = .default) {
        logger.log(level: type, "\(message, privacy: .public)")
    }
}
