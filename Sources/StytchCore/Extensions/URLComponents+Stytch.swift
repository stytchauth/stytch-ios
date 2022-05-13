import Foundation

extension URLComponents {
    var isLocalHost: Bool {
        switch host {
        case "localhost", "[::1]", Regex("^127(?:\\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$"):
            return true
        default:
            return false
        }
    }
}
