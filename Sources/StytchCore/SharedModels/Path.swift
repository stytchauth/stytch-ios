import Foundation

public struct Path {
    let rawValue: String
}

extension Path: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        rawValue = value
    }
}

extension Path {
    func appendingPath(_ path: Path) -> Self {
        .init(
            rawValue: [rawValue, path.rawValue]
                .compactMap { $0.trimmingCharacters(in: .forwardSlash).presence }
                .joined(separator: "/")
        )
    }
}

extension String {
    func appendingPath(_ path: Path) -> Path {
        .init(rawValue: self).appendingPath(path)
    }
}

private extension CharacterSet {
    static let forwardSlash: Self = .init(charactersIn: "/")
}
