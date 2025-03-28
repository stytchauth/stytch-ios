import Combine
import Foundation

struct ErrorPublisher {
    private static let errorPublisher = PassthroughSubject<Error, Never>()

    static var publisher: AnyPublisher<Error, Never> {
        errorPublisher.eraseToAnyPublisher()
    }

    static func publishError(_ error: Error) {
        errorPublisher.send(error)
    }
}
