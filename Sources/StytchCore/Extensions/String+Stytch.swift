import Foundation

extension String {
    var completeRange: NSRange {
        .init(location: 0, length: count)
    }

    func base64Encoded() -> String {
        Data(utf8).base64EncodedString()
    }

    var presence: String? {
        isEmpty ? nil : self
    }
}

extension Optional where Wrapped == String {
    var presence: String? {
        flatMap(\.presence)
    }
}

extension String: RegexMatchable {
    func match(_ regex: Regex) -> Bool {
        regex.match(self)
    }
}

extension Optional: RegexMatchable where Wrapped == String {
    func match(_ regex: Regex) -> Bool {
        map { $0.match(regex) } ?? false
    }
}
