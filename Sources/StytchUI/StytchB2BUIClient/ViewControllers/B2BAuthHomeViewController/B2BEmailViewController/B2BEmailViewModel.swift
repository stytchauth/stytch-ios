import StytchCore

final class B2BEmailViewModel {
    let state: B2BEmailState

    init(
        state: B2BEmailState
    ) {
        self.state = state
    }

    func sendEmailMagicLink(
        emailAddress: String,
        completion: @escaping (Error?) -> Void
    ) {
        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await AuthenticationOperations.sendEmailMagicLinkForAuthFlowType(configuration: state.configuration, emailAddress: emailAddress)
                completion(nil)
                StytchB2BUIClient.stopLoading()
            } catch {
                completion(error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }

    func sendEmailOTP(
        emailAddress: String,
        completion: @escaping (Error?) -> Void
    ) {
        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await AuthenticationOperations.sendEmailOTPForAuthFlowType(configuration: state.configuration, emailAddress: emailAddress)
                completion(nil)
                StytchB2BUIClient.stopLoading()
            } catch {
                completion(error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}

struct B2BEmailState {
    let configuration: StytchB2BUIClient.Configuration
}
