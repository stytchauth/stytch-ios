import Combine
import StytchCore
import UIKit

final class SearchManagerViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var searchMemberButton: UIButton = .init(title: "Search Member", primaryAction: .init { [weak self] _ in
        self?.searchMember()
    })

    lazy var searchOrganizationButton: UIButton = .init(title: "Search Organization", primaryAction: .init { [weak self] _ in
        self?.searchOrganization()
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Manager"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(searchMemberButton)
        stackView.addArrangedSubview(searchOrganizationButton)
    }

    func searchMember() {
        Task {
            do {
                guard let organizationId = self.organizationId else {
                    return
                }
                guard let emailAddress = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Email Address") else {
                    throw TextFieldAlertError.emptyString
                }
                let parameters = StytchB2BClient.SearchManager.SearchMemberParameters(emailAddress: emailAddress, organizationId: organizationId)
                let response = try await StytchB2BClient.searchManager.searchMember(searchMemberParameters: parameters)
                presentAlertAndLogMessage(description: "search member success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "search member error", object: error)
            }
        }
    }

    func searchOrganization() {
        Task {
            do {
                guard let organizationSlug = try await presentTextFieldAlertWithTitle(alertTitle: "Enter Organization Slug") else {
                    throw TextFieldAlertError.emptyString
                }

                let parameters = StytchB2BClient.SearchManager.SearchOrganizationParameters(organizationSlug: organizationSlug)
                let response = try await StytchB2BClient.searchManager.searchOrganization(searchOrganizationParameters: parameters)
                presentAlertAndLogMessage(description: "search organizations success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "search organizations error", object: error)
            }
        }
    }
}
