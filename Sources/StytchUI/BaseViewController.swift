import UIKit

class BaseViewController<_State, _Action>: UIViewController {
    typealias State = _State
    typealias Action = _Action

    private let actionTransformer: (Action) -> AuthHomeAction

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

    init(state: State, actionTransformer: @escaping (Action) -> AuthHomeAction) {
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

    final func perform(action: Action) {
        willPerform(action: action)
        actionDelegate?.handle(action: actionTransformer(action))
    }

    func willPerform(action: Action) {}

    func stateDidUpdate(state: State) {}
}

protocol ActionDelegate {
    func handle(action: AuthHomeAction)
}

extension UIResponder {
    var actionDelegate: ActionDelegate? {
        if let delegate = next as? ActionDelegate {
            return delegate
        }
        return next?.actionDelegate
    }
}

extension BaseViewController where State == Empty {
    convenience init(_ state: State = .init(), actionTransformer: @escaping (Action) -> AuthHomeAction) {
        self.init(state: state, actionTransformer: actionTransformer)
    }
}
