import UIKit

protocol BaseViewControllerProtocol {
    associatedtype ViewModel

    var stackView: UIStackView { get }
    var viewModel: ViewModel { get }

    func configureView()
}

class BaseViewController<State, ViewModel>: UIViewController, BaseViewControllerProtocol {
    var viewModel: ViewModel

    private(set) lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = .spacingRegular
        return view
    }()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
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
