import UIKit

class BaseViewController<ControllerAction, Configuration>: UIViewController {
    private let actionDelegate: (ControllerAction) -> Void

    let configuration: Configuration

    init(configuration: Configuration, actionDelegate: @escaping (ControllerAction) -> Void) {
        self.configuration = configuration
        self.actionDelegate = actionDelegate

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    final func perform(action: ControllerAction) {
        willPerform(action: action)
        actionDelegate(action)
    }

    func willPerform(action: ControllerAction) {}
}
