import Combine

public class InitializationState {
    private let isInitializedPublisher = PassthroughSubject<Bool, Never>()
    public var isInitialized: AnyPublisher<Bool, Never> { isInitializedPublisher.eraseToAnyPublisher() }
    func setInitializationState(state: Bool) {
        isInitializedPublisher.send(state)
    }
}
