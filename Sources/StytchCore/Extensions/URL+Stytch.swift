import Foundation

public extension Dictionary where Key == String, Value == String {
    func toURLParameters() -> String {
        let urlComponents = map { key, value in
            let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(key)=\(escapedValue)"
        }
        return urlComponents.joined(separator: "&")
    }
}
