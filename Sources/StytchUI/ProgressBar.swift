import UIKit

final class ProgressBar: UIView {
    enum Progress: Int {
        case one = 0
        case two
        case three
        case four
    }

    override var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: .spacingTiny)
    }

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = .spacingTiny
        return view
    }()

    private let block0: UIView = .init()

    private let block1: UIView = .init()

    private let block2: UIView = .init()

    private let block3: UIView = .init()

    var progress: Progress? {
        didSet {
            guard let progress else {
                stackView.arrangedSubviews.forEach { view in
                    view.backgroundColor = .placeholder
                }
                return
            }
            let progressColor: UIColor = progress.rawValue < 2 ?
                .error :
                .brand

            stackView.arrangedSubviews.enumerated().forEach { index, view in
                view.backgroundColor = index <= progress.rawValue ? progressColor : .placeholder
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.distribution = .fillEqually

        stackView.addArrangedSubview(block0)
        stackView.addArrangedSubview(block1)
        stackView.addArrangedSubview(block2)
        stackView.addArrangedSubview(block3)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        stackView.arrangedSubviews.forEach { $0.backgroundColor = .placeholder }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
