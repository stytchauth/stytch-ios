import Foundation
import UIKit
import WebKit

class EnterOTPViewController: UIViewController {

    @objc public weak var delegate: StytchSMSUIDelegate?

    // MARK: Private Vars

    let phoneNumber: String

    // MARK: UI Components

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StytchMagicLinkUI.shared.customization.titleStyle.font.withSize(StytchMagicLinkUI.shared.customization.titleStyle.size)
        label.numberOfLines = 0
        //label.attributedText
        label.text = "Enter passcode".localized
        label.textColor = StytchMagicLinkUI.shared.customization.titleStyle.color
        return label
    }()
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StytchMagicLinkUI.shared.customization.subtitleStyle.font.withSize(StytchMagicLinkUI.shared.customization.subtitleStyle.size)
        label.numberOfLines = 0
        label.text =
            String(format: "A 6-digit passcode was sent to you at %@".localized, phoneNumber)
        label.textColor = StytchMagicLinkUI.shared.customization.subtitleStyle.color
        return label
    }()
    lazy var textFields: [StytchDigitTextField] = {
        var textFields = [StytchDigitTextField]()
        for i in 0..<6{
            let textField = StytchDigitTextField(customization: StytchMagicLinkUI.shared.customization)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.placeholderText = "0"
            textField.textField.delegate = self
            textField.textField.tag = i
            textField.textField.keyboardType = .numberPad
            textFields.append(textField)
        }
        textFields.first?.textField.becomeFirstResponder()
        return textFields
    }()
    var resentLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString()
            .normal("Didn't get it?".localized)
            .normal(" ")
            .bold("Resend code".localized)

        return label
    }()

    lazy var actionButton: StytchActionButton = {
        let button = StytchActionButton(customization: StytchMagicLinkUI.shared.customization)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Continue".localized, for: .normal)
        button.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        return button
    }()
    var poweredView: StytchPoweredView = {
        let view = StytchPoweredView(customization: StytchMagicLinkUI.shared.customization)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = StytchMagicLinkUI.shared.customization.backgroundColor.invertedWhiteBlack
        view.isHidden = true
        return view
    }()

    // MARK: Parameters

    var buttonTopToSubtitileConstraint: NSLayoutConstraint!
    var buttonTopToTextFieldConstraint: NSLayoutConstraint!

    // MARK: Initializers

    init(phoneNumber: String){
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = StytchMagicLinkUI.shared.customization.backgroundColor

        hideKeyboardWhenTappedAround()

        setupViews()
    }

    func setupViews() {

        var lastTopAnchor = view.safeAreaLayoutGuide.topAnchor
        var lastTopPadding: CGFloat = 32

        if StytchMagicLinkUI.shared.customization.showTitle {
            view.addSubview(titleLabel)
            titleLabel.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))

            lastTopAnchor = titleLabel.bottomAnchor
            lastTopPadding = 24
        }

        if StytchMagicLinkUI.shared.customization.showSubtitle {
            view.addSubview(subtitleLabel)
            subtitleLabel.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))

            lastTopAnchor = subtitleLabel.bottomAnchor
            lastTopPadding = 24
        }

        let stackView = UIStackView(arrangedSubviews: textFields)
        stackView.spacing = 6
        stackView.distribution = .equalCentering
        view.addSubview(stackView)
        stackView.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: 23, left: 24, bottom: 0, right: 24))

        for textField in textFields{
            textField.constraintSize(CGSize(width: 40, height: 40))
        }

        lastTopAnchor = stackView.bottomAnchor

        view.addSubview(resentLabel)

        resentLabel.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))

        lastTopAnchor = resentLabel.bottomAnchor

        view.addSubview(actionButton)

        actionButton.anchor(top: lastTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .init(top: lastTopPadding, left: 24, bottom: 0, right: 24))

        if StytchMagicLinkUI.shared.customization.showBrandLogo {
            view.addSubview(poweredView)
            poweredView.anchor(top: actionButton.bottomAnchor, left: nil, bottom: nil, right: nil, padding: .init(top: 0, left: 24, bottom: 0, right: 24))
            poweredView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }

        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

    }

    func showLoading() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    func hideLoading() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }

    // MARK: Actions

    @objc func handleActionButton() {
        let fields = textFields.map { $0.textField.text ?? ""}
        let code = fields.joined()
        guard code.count == StytchOTP.codeLength else{
            //@Ethan present error for incomplete code
            return
        }
        showLoading()
        Stytch.shared.otp.authenticateOTP(code, success: { [weak self] smsModel in
            DispatchQueue.main.async{
                self?.hideLoading()
                let result = StytchResult(userId: smsModel.userId, requestId: smsModel.requestId)
                self?.delegate?.onSuccess?(result)
            }
        }, failure: { [weak self] error in
            DispatchQueue.main.async{
                self?.hideLoading()
                self?.delegate?.onFailure?(error)
            }
        })
    }
}

extension EnterOTPViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn: NSRange, replacementString: String) -> Bool{
        if replacementString.count == 6{
            for (index, character) in replacementString.enumerated(){
                textFields[index].text = "\(character)"
            }
            return false
        }else{

            print("@Ethan :\(replacementString):  -> \(replacementString.count)")
            //if its not a backspace, then select the next text box.

            let textFieldIndex = textField.tag
            textField.text = replacementString
            if replacementString.count == 0{
                if textFieldIndex - 1 >= 0{
                    let text = textFields[textFieldIndex - 1].textField.text
                    textFields[textFieldIndex - 1].textField.becomeFirstResponder()
                    textFields[textFieldIndex - 1].textField.text = (text ?? "") + " "
                }
            }else{
                if textFieldIndex + 1 < textFields.count{
                    textFields[textFieldIndex + 1].textField.becomeFirstResponder()
                }
            }
            if ((textField.text?.count ?? 0) + replacementString.count) > 1{
                return false
            }
            return true
        }
    }
}
