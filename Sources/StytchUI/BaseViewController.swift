import UIKit

class BaseViewController<_Config, _State, _Action>: UIViewController {
    typealias Config = _Config
    typealias State = _State
    typealias Action = _Action

    private let actionTransformer: (Action) -> AppAction

    let config: Config

    var state: State {
        didSet {
            stateDidUpdate(state: state)
        }
    }

    private(set) lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = .spacingRegular
        return view
    }()

    init(config: Config, state: State, actionTransformer: @escaping (Action) -> AppAction) {
        self.config = config
        self.state = state
        self.actionTransformer = actionTransformer

        super.init(nibName: nil, bundle: nil)

        stateDidUpdate(state: state)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.layoutMargins = .default
    }

    final func attachStackView(within superview: UIView) {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: superview.layoutMarginsGuide.widthAnchor),
            stackView.leadingAnchor.constraint(equalTo: superview.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: superview.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: superview.layoutMarginsGuide.bottomAnchor),
        ])
    }

    final func perform(action: Action) {
        willPerform(action: action)
        actionDelegate?.handle(action: actionTransformer(action))
    }

    func willPerform(action: Action) {}

    func stateDidUpdate(state: State) {}
}

protocol ActionDelegate {
    func handle(action: AppAction)
}

extension UIResponder {
    var actionDelegate: ActionDelegate? {
        if let delegate = next as? ActionDelegate {
            return delegate
        }
        return next?.actionDelegate
    }
}

extension BaseViewController where Config == Empty {
    convenience init(_ config: Config = .init(), state: State, actionTransformer: @escaping (Action) -> AppAction) {
        self.init(config: config, state: state, actionTransformer: actionTransformer)
    }
}

extension BaseViewController where State == Empty {
    convenience init(_ config: Config, state: State = .init(), actionTransformer: @escaping (Action) -> AppAction) {
        self.init(config: config, state: state, actionTransformer: actionTransformer)
    }
}
