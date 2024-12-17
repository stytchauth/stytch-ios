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
        "Looks like there was an error!"
    }

    var subtitle: String {
        switch state.type {
        case .noOrganziationFound:
            return "The organization you are looking for could not be found. If you think this is a mistake, contact your admin."
        case .noPrimaryAuthMethods:
            return "Unable to join due to \(OrganizationManager.organizationName ?? "the organization")'s authentication policy. Please contact your admin for more information."
        case .emailAuthFailed:
            return "Something went wrong. Your login link may have expired, been revoked, or been used more than once. Request a new login link to try again, or contact your admin for help."
        case .generic:
            return "Something went wrong. Try again later or contact your admin for help."
        case .invlaidProductConfiguration:
            return "Invalid product configuration detected"
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
