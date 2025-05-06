import StytchCore

final class ErrorViewModel {
    let state: ErrorState

    init(
        state: ErrorState
    ) {
        self.state = state
    }
}

extension ErrorViewModel {
    var title: String {
        LocalizationManager.stytch_b2b_error_title
    }

    var subtitle: String {
        switch state.type {
        case .noOrganziationFound:
            return LocalizationManager.stytch_b2b_error_no_org_found
        case .noPrimaryAuthMethods:
            return LocalizationManager.stytch_b2b_error_no_primary_auth_methods(orgName: OrganizationManager.name ?? "the organization")
        case .emailAuthFailed:
            return LocalizationManager.stytch_b2b_error_email_auth_failed
        case .generic:
            return LocalizationManager.stytch_b2b_error_generic
        case .invlaidProductConfiguration:
            return LocalizationManager.stytch_b2b_error_invalid_product_configuration
        }
    }
}

struct ErrorState {
    let configuration: StytchB2BUIClient.Configuration
    let type: ErrorScreenType
}

enum ErrorScreenType: Error {
    case noOrganziationFound
    case noPrimaryAuthMethods
    case emailAuthFailed
    case invlaidProductConfiguration
    case generic
}
