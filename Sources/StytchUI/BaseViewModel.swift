protocol BaseState {
    var config: StytchUIClient.Configuration { get }
}

protocol BaseViewModelDelegate {}

protocol BaseViewModelProtocol {
    associatedtype State
    associatedtype Delegate

    var delegate: Delegate { get }

    var state: State { get }

    init(state: State)

    func update(state: State)
}

class BaseViewModel<State: BaseState, Delegate: BaseViewModelDelegate>: BaseViewModelProtocol {
    var delegate: Delegate?

    var state: State {
        didSet {
            update(state: state)
        }
    }

    required init(state: State) {
        self.state = state
    }

    func update(state: State) {}
}
