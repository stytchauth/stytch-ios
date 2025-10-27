import StytchCore
import UIKit

protocol BaseViewControllerProtocol {
    associatedtype ViewModel

    var stackView: UIStackView { get }
    var viewModel: ViewModel { get }

    func configureView()
}

class BaseViewController<State, ViewModel>: UIViewController, BaseViewControllerProtocol {
    var viewModel: ViewModel

    var stackView = UIStackView()

    lazy var poweredByStytchView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        containerView.clipsToBounds = true

        let imageView = UIImageView(image: ImageAsset.poweredByStytch.image)
        imageView.accessibilityLabel = "poweredByStytch"
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(imageView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 35),

            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 19),
            imageView.widthAnchor.constraint(equalToConstant: 142),
        ])

        return containerView
    }()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = .spacingLarge

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHideKeyboardOnTap()
        configureView()
    }

    func configureView() {
        view.backgroundColor = .background
        view.layoutMargins = .default
    }

    func attachStackViewToScrollView() {
        let scrollView: UIScrollView = .init()
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])

        attachStackView(within: scrollView, usingLayoutMarginsGuide: false)
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

    func hideBackButton() {
        navigationItem.hidesBackButton = true
    }

    @objc func dismissAuth() {
        presentingViewController?.dismiss(animated: true)
    }

    func configureCloseButton(_ navigation: Navigation?) {
        guard let closeButton = navigation?.closeButtonStyle else {
            return
        }

        let closeBarButton = UIBarButtonItem(
            barButtonSystemItem: closeButton.barButtonSystemItem,
            target: self,
            action: #selector(dismissAuth)
        )

        if closeButton.position == .left {
            navigationItem.leftBarButtonItem = closeBarButton
        } else if closeButton.position == .right {
            navigationItem.rightBarButtonItem = closeBarButton
        }
    }

    func setupPoweredByStytchView() {
        view.addSubview(poweredByStytchView)

        NSLayoutConstraint.activate([
            poweredByStytchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            poweredByStytchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            poweredByStytchView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func setupHideKeyboardOnTap() {
        view.addGestureRecognizer(endEditingRecognizer())
        navigationController?.navigationBar.addGestureRecognizer(endEditingRecognizer())
    }

    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
