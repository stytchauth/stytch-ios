import Foundation

public struct Navigation: Codable {
    let closeButtonStyle: CloseButtonStyle?

    /// - Parameter closeButtonStyle: Determines the type of close button used on the root view as well as its position.
    public init(closeButtonStyle: CloseButtonStyle? = .close(.right)) {
        self.closeButtonStyle = closeButtonStyle
    }

    public enum CloseButtonStyle: Codable {
        case cancel(BarButtonPosition = .right)
        case close(BarButtonPosition = .right)
        case done(BarButtonPosition = .right)
    }

    public enum BarButtonPosition: Codable {
        case left
        case right
    }
}
