import Foundation

extension String {
    var completeRange: NSRange {
        .init(location: 0, length: count)
    }

    func base64Encoded() -> String {
        Data(utf8).base64EncodedString()
    }

    func dropLast(while predicate: (Character) throws -> Bool) rethrows -> Substring {
        try Substring(reversed().drop(while: predicate).reversed())
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
