import Foundation
import UIKit

// swiftlint:disable type_contents_order

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

        var barButtonSystemItem: UIBarButtonItem.SystemItem {
            switch self {
            case .cancel:
                return .cancel
            case .close:
                return .close
            case .done:
                return .done
            }
        }

        var position: Navigation.BarButtonPosition {
            switch self {
            case let .cancel(position), let .close(position), let .done(position):
                return position
            }
        }
    }

    public enum BarButtonPosition: Codable {
        case left
        case right
    }
}
