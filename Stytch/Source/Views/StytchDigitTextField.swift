//
//  StytchTextField.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit

class StytchDigitTextField: UIView {

    var customization: StytchUICustomization

    lazy private var borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = customization.inputBackgroundColor
        view.layer.borderWidth = 1
        view.layer.borderColor = customization.inputBorderColor.cgColor
        view.layer.cornerRadius = customization.inputCornerRadius
        return view
    }()

    lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textColor = customization.inputTextStyle.color
        field.font = customization.inputTextStyle.font.withSize(customization.inputTextStyle.size)
        field.delegate = self
        field.addTarget(self, action: #selector(fieldDidChanged), for: .valueChanged)
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = .numberPad
        return field
    }()

    @objc func fieldDidChanged() {

    }

    var placeholderText = "" {
        didSet {
            let placeholderColor = customization.inputPlaceholderStyle.color
            let placeholderFont = customization.inputPlaceholderStyle.font.withSize(customization.inputPlaceholderStyle.size)
            let attributedText = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor : placeholderColor, NSAttributedString.Key.font: placeholderFont])
            textField.attributedPlaceholder = attributedText
        }
    }
    var text: String {
        set {
            textField.text = newValue
            checkStatus()
        }
        get {
            return textField.text ?? ""
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(frame: CGRect = .zero, customization: StytchUICustomization) {
        self.customization = customization
        super.init(frame: frame)
        backgroundColor = customization.backgroundColor
        checkStatus()
        setupViews()
    }

    private func setupViews() {
        addSubview(borderView)
        borderView.addSubview(textField)

        borderView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

        textField.fillSuperview(padding: .init(top: 10, left: 15, bottom: 10, right: 15))
    }

    private func checkStatus() {

    }

    func setupErrorState() {

    }
}

extension StytchDigitTextField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        checkStatus()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        checkStatus()
    }
}
