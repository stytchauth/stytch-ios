import Foundation

extension URL {
    func appendingPathComponent(_ pathComponent: Path) -> URL {
        appendingPathComponent(pathComponent.rawValue)
    }
}
