import StytchCore

final class CreateOrganizationsViewModel {
    let state: CreateOrganizationsState

    init(
        state: CreateOrganizationsState
    ) {
        self.state = state
    }

    func createOrganization() async throws {
        let response = try await StytchB2BClient.discovery.createOrganization(parameters: .init())
        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
    }
}

struct CreateOrganizationsState {
    let configuration: StytchB2BUIClient.Configuration
}
