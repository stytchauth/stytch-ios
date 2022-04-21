import Foundation

extension URL {
    func appendingPathComponent(_ pathComponent: Path) -> URL {
        appendingPathComponent(pathComponent.rawValue)
    }

    func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        var newQueryItems = components.queryItems ?? []
        newQueryItems.append(contentsOf: queryItems)
        components.queryItems = newQueryItems
        return components.url ?? self
    }
}
