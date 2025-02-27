import Foundation

extension Array where Element: Equatable {
    mutating func appendIfNotPresent(_ element: Element) {
        if contains(element) == false {
            append(element)
        }
    }
}
