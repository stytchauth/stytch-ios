import Foundation

struct PathTag {}

typealias Path = Tagged<PathTag, String>

extension Path {
    func appendingPathComponent(_ pathComponent: String) -> Path {
        .init(
            rawValue: [rawValue, pathComponent]
                .compactMap { component in
                    let trimmedComponent = component.trimmingCharacters(in: .forwardSlash)
                    return trimmedComponent.isEmpty ? nil : trimmedComponent
                }
                .joined(separator: "/")
        )
    }
}

private extension CharacterSet {
    static let forwardSlash: Self = .init(charactersIn: "/")
}
