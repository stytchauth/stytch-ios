// swiftlint:disable:this file_name

import CoreFoundation

extension Optional where Wrapped == Unmanaged<CFError> {
    func toError() -> Error? {
        self?.asError
    }
}

extension Unmanaged where Instance == CFError {
    var asError: Error {
        takeRetainedValue() as Error
    }
}
