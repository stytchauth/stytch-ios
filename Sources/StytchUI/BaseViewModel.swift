protocol BaseViewModelProtocol {
    associatedtype State
    associatedtype Action

    var state: State { get }

    init(state: State)

    func updateState(_ state: State)

    func performAction(_ action: Action)
}

class BaseViewModel<State: BaseViewState, Action: BaseViewAction>: BaseViewModelProtocol {
    var state: State {
        didSet {
            updateState(state)
        }
    }

    required init(state: State) {
        self.state = state
    }

    func updateState(_ state: State) {}

    func performAction(_ action: Action) {}
}
