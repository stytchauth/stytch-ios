import UIKit

class BorderedTextField: UITextField {
    override var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: .buttonHeight)
    }

    var insets: UIEdgeInsets = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.placeholder.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = .cornerRadius
        insets = .init(top: 0, left: 10, bottom: 0, right: 10)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: insets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: insets)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        super.rightViewRect(forBounds: bounds).offsetBy(dx: -insets.right, dy: 0)
    }
}

extension UITextField {
    func applyBorderedStyle() {
        layer.borderColor = UIColor.placeholder.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = .cornerRadius
        leftView = .init(frame: .init(origin: .zero, size: .init(width: 10, height: 10)))
        leftViewMode = .always
    }
}
