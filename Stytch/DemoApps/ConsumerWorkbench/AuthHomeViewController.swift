import StytchCore
import StytchUI
import UIKit

final class AuthHomeViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Consumer Authentication Products"

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    static var publicToken: String {
        UserDefaults.standard.string(forKey: publicTokenDefaultsKey) ?? ""
    }
}

extension AuthHomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
