import Foundation

protocol RegexMatchable {
    func match(_ regex: Regex) -> Bool
}

struct Regex {
    private let regex: NSRegularExpression

    init(_ staticPattern: StaticString) {
        let pattern: String = staticPattern.withUTF8Buffer { buffer in
            String(decoding: buffer, as: UTF8.self)
        }
        // swiftlint:disable:next force_try
        regex = try! NSRegularExpression(pattern: pattern)
    }

    static func ~= (regex: Self, matchable: RegexMatchable) -> Bool {
        matchable.match(regex)
    }

    func match(_ string: String) -> Bool {
        regex.firstMatch(in: string, range: string.completeRange) != nil
    }
}
