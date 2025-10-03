import Combine
import StytchCore
import UIKit

final class OrganizationMemberSearchViewController: UIViewController {
    private let stackView = UIStackView.stytchStackView()

    private lazy var searchAllMembersButton: UIButton = .init(title: "Search all members", primaryAction: .init { [weak self] _ in
        self?.searchAllMembers()
    })

    private lazy var searchBySingleEmailButton: UIButton = .init(title: "Search by single email", primaryAction: .init { [weak self] _ in
        self?.searchBySingleEmail()
    })
    private lazy var searchByMultipleEmailsButton: UIButton = .init(title: "Search by multiple emails", primaryAction: .init { [weak self] _ in
        self?.searchByMultipleEmails()
    })
    private lazy var searchByEmailFuzzyButton: UIButton = .init(title: "Search by email fuzzy", primaryAction: .init { [weak self] _ in
        self?.searchByEmailFuzzy()
    })
    private lazy var searchByBreakglassTrueButton: UIButton = .init(title: "Search breakglass true", primaryAction: .init { [weak self] _ in
        self?.searchByBreakglassTrue()
    })
    private lazy var searchByPasswordExistsFalseButton: UIButton = .init(title: "Search password exists false", primaryAction: .init { [weak self] _ in
        self?.searchByPasswordExistsFalse()
    })
    private lazy var searchByStatusesButton: UIButton = .init(title: "Search by statuses", primaryAction: .init { [weak self] _ in
        self?.searchByStatuses()
    })
    private lazy var searchByRolesButton: UIButton = .init(title: "Search by roles", primaryAction: .init { [weak self] _ in
        self?.searchByRoles()
    })
    private lazy var searchAndEmailsAndPasswordButton: UIButton = .init(title: "Search AND emails and password", primaryAction: .init { [weak self] _ in
        self?.searchAndEmailsAndPassword()
    })
    private lazy var searchOrFuzzyEmailOrFuzzyPhoneButton: UIButton = .init(title: "Search OR fuzzy email or fuzzy phone", primaryAction: .init { [weak self] _ in
        self?.searchOrFuzzyEmailOrFuzzyPhone()
    })
    private lazy var searchWithPaginationSmallLimitButton: UIButton = .init(title: "Search with small limit for pagination", primaryAction: .init { [weak self] _ in
        self?.searchWithPaginationSmallLimit()
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Organization Member Search"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Buttons
        stackView.addArrangedSubview(searchAllMembersButton)
        stackView.addArrangedSubview(searchBySingleEmailButton)
        stackView.addArrangedSubview(searchByMultipleEmailsButton)
        stackView.addArrangedSubview(searchByEmailFuzzyButton)
        stackView.addArrangedSubview(searchByBreakglassTrueButton)
        stackView.addArrangedSubview(searchByPasswordExistsFalseButton)
        stackView.addArrangedSubview(searchByStatusesButton)
        stackView.addArrangedSubview(searchByRolesButton)
        stackView.addArrangedSubview(searchAndEmailsAndPasswordButton)
        stackView.addArrangedSubview(searchOrFuzzyEmailOrFuzzyPhoneButton)
        stackView.addArrangedSubview(searchWithPaginationSmallLimitButton)
    }

    // MARK: - Demo search builders

    private func searchAllMembers() {
        Task {
            let operands: [any SearchQueryOperand] = []
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .AND
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "all members")
        }
    }

    private func searchBySingleEmail() {
        Task {
            let operands = makeOperands([
                (.memberEmails, ["foo@stytch.com"]),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .AND
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "single email")
        }
    }

    private func searchByMultipleEmails() {
        Task {
            let operands = makeOperands([
                (.memberEmails, ["alpha@example.com", "beta@example.com"]),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .OR
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "multiple emails OR")
        }
    }

    private func searchByEmailFuzzy() {
        Task {
            let operands = makeOperands([
                (.memberEmailFuzzy, "ali"),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .AND
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "email fuzzy")
        }
    }

    private func searchByBreakglassTrue() {
        Task {
            let operands = makeOperands([
                (.memberIsBreakglass, true),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .AND
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "breakglass true")
        }
    }

    private func searchByPasswordExistsFalse() {
        Task {
            let operands = makeOperands([
                (.memberPasswordExists, false),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .AND
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "password exists false")
        }
    }

    private func searchByStatuses() {
        Task {
            let operands = makeOperands([
                (.statuses, ["active", "invited"]),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .OR
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "statuses")
        }
    }

    private func searchByRoles() {
        Task {
            let operands = makeOperands([
                (.memberRoles, ["admin", "member"]),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .OR
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "roles")
        }
    }

    private func searchAndEmailsAndPassword() {
        Task {
            let operands = makeOperands([
                (.memberEmails, ["alpha@example.com"]),
                (.memberPasswordExists, true),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .AND
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "AND emails and password")
        }
    }

    private func searchOrFuzzyEmailOrFuzzyPhone() {
        Task {
            let operands = makeOperands([
                (.memberEmailFuzzy, "ali"),
                (.memberMfaPhoneNumberFuzzy, "401"),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .OR
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: nil, label: "OR email fuzzy or phone fuzzy")
        }
    }

    private func searchWithPaginationSmallLimit() {
        Task {
            let operands = makeOperands([
                (.memberEmails, ["alpha@example.com", "beta@example.com", "gamma@example.com"]),
            ])
            let queryOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator = .OR
            await performSearch(operands: operands, operator: queryOperator, cursor: nil, limit: 2, label: "pagination with small limit")
        }
    }

    // MARK: - Common helpers

    private func performSearch(
        operands: [any SearchQueryOperand],
        operator searchOperator: StytchB2BClient.Organizations.SearchParameters.SearchOperator,
        cursor: String?,
        limit: Int?,
        label: String
    ) async {
        do {
            let query = StytchB2BClient.Organizations.SearchParameters.SearchQuery(
                searchOperator: searchOperator,
                searchOperands: operands
            )
            let parameters = StytchB2BClient.Organizations.SearchParameters(
                query: query,
                cursor: cursor,
                limit: limit
            )
            let response = try await StytchB2BClient.organizations.searchMembers(parameters: parameters)
            print("search \(label) members count: \(response.members.count)")
            if let nextCursor = response.resultsMetadata.nextCursor {
                print("search \(label) next_cursor: \(nextCursor)")
            }
            presentAlertAndLogMessage(description: "search \(label) success", object: response)
        } catch {
            presentAlertAndLogMessage(description: "search \(label) error", object: error)
        }
    }

    private func makeOperands(_ inputs: [(StytchB2BClient.Organizations.SearchParameters.SearchQueryOperandFilterNames, Any)]) -> [any SearchQueryOperand] {
        var builtOperands = [any SearchQueryOperand]()
        for input in inputs {
            if let operand = StytchB2BClient.Organizations.SearchParameters.searchQueryOperand(
                filterName: input.0,
                filterValue: input.1
            ) {
                builtOperands.append(operand)
            } else {
                print("Invalid operand skipped for filter \(input.0.rawValue)")
            }
        }
        return builtOperands
    }
}
