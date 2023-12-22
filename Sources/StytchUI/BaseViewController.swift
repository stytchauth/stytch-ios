import UIKit

protocol BaseState {}

protocol BaseAction {}

protocol BaseViewModelProtocol {
    associatedtype State
    associatedtype Action

    var state: State { get }

    init(state: State)

    func update(state: State)

    func perform(action: Action) async throws
}

class BaseViewModel<State: BaseState, Action: BaseAction>: BaseViewModelProtocol {
    var state: State {
        didSet {
            update(state: state)
        }
    }

    required init(state: State) {
        self.state = state
    }

    func update(state: State) {}

    func perform(action: Action) async throws {}
}

protocol BaseViewControllerProtocol {
    associatedtype State
    associatedtype Action
    associatedtype ViewModel

    var stackView: UIStackView { get }
    var viewModel: ViewModel { get }

    init(state: State)

    func configureView()

    func update(state: State)
}

class BaseViewController<State: BaseState, Action: BaseAction, ViewModel: BaseViewModel<State, Action>>: UIViewController, BaseViewControllerProtocol {

    var viewModel: ViewModel

    private(set) lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = .spacingRegular
        return view
    }()

    required init(state: State) {
        viewModel = ViewModel(state: state)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        view.backgroundColor = .background
        view.layoutMargins = .default
    }

    func update(state: State) {}

    final func attachStackView(within superview: UIView, usingLayoutMarginsGuide: Bool = true) {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(stackView)
        if usingLayoutMarginsGuide {
            NSLayoutConstraint.activate([
                stackView.widthAnchor.constraint(equalTo: superview.layoutMarginsGuide.widthAnchor),
                stackView.leadingAnchor.constraint(equalTo: superview.layoutMarginsGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: superview.layoutMarginsGuide.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: superview.layoutMarginsGuide.bottomAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                stackView.widthAnchor.constraint(equalTo: superview.widthAnchor),
                stackView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: superview.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            ])
        }
    }
}
