import Foundation

if ProcessInfo.processInfo.environment["DEMO_SERVER_SCRIPT"] == nil {
    preconditionFailure("Server should be started by running `Scripts/demo-server start` from the commandline.")
}

var args = ProcessInfo.processInfo.arguments.dropFirst()

guard let port = UInt16(args.removeFirst())
else { fatalError("Expected an integer value for the port as the first argument") }

startServer(port: port)
