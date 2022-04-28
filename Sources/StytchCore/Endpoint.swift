import Foundation
import Tagged

struct Endpoint {
    let path: Path
    let queryItems: [URLQueryItem]

    init(path: Path, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }

    func url(baseUrl: URL) -> URL {
        guard var components = URLComponents(
            url: baseUrl.appendingPathComponent(path.rawValue),
            resolvingAgainstBaseURL: true
        ) else {
            return baseUrl
        }

        var newQueryItems = components.queryItems ?? []
        newQueryItems.append(contentsOf: queryItems)
        components.queryItems = newQueryItems
        return components.url ?? baseUrl
    }
}

extension Endpoint {
    typealias Path = Tagged<PathTag, String>

    enum PathTag {}
}

extension Endpoint.Path {
    func appendingPathComponent(_ pathComponent: String) -> Self {
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
