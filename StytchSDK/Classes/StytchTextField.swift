//
//  StytchTextField.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-17.
//

import UIKit

class StytchTextField: UIView {
    
    private var borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StytchUI.shared.customization.inputBackgroundColor
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.22).cgColor
        view.layer.cornerRadius = 6
        return view
    }()

    
    lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textColor = StytchUI.shared.customization.inputTextStyle.color
        field.font = StytchUI.shared.customization.inputTextStyle.font.withSize(StytchUI.shared.customization.inputTextStyle.size)
        field.delegate = self
        field.addTarget(self, action: #selector(fieldDidChanged), for: .valueChanged)
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = .emailAddress
        return field
    }()
    
    @objc func fieldDidChanged() {
        
    }
    
    var placeholderText = "" {
        didSet {
            let placeholderColor = StytchUI.shared.customization.inputPlaceholderStyle.color
            let placeholderFont = StytchUI.shared.customization.inputPlaceholderStyle.font.withSize(StytchUI.shared.customization.inputPlaceholderStyle.size)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = StytchUI.shared.customization.backgroundColor
        checkStatus()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(borderView)
        borderView.addSubview(textField)
        
        borderView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        textField.fillSuperview(padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    private func checkStatus() {
        
//        if textField.isEditing {
//            borderView.layer.borderColor = Colors.TintColor.cgColor
//        } else {
//            if text.isEmpty == true {
//                borderView.layer.borderColor = Colors.ComponentBorderColor.cgColor
//            } else {
//                borderView.layer.borderColor = Colors.ComponentBorderColor.cgColor
//            }
//        }

    }
    
    func setupErrorState() {
//        borderView.layer.borderColor = Colors.AppRedColor.cgColor
    }
}

extension StytchTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        checkStatus()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkStatus()
    }
}
