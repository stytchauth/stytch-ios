import Foundation

extension Optional where Wrapped == String {
    var presence: String? {
        flatMap(\.presence)
    }
}

extension String {
    var presence: String? {
        isEmpty ? nil : self
    }
}
