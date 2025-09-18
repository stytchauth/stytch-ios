import Foundation
import StytchCore

final class EmailOTPEntryViewModel {
    let state: EmailOTPEntryState

    init(
        state: EmailOTPEntryState
    ) {
        self.state = state
    }

    func emailAuthenticate(code: String) async throws {
        let emailAddress = MemberManager.emailAddress ?? ""

        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        let parameters = StytchB2BClient.OTP.Email.AuthenticateParameters(
            code: code,
            organizationId: organizationId,
            emailAddress: emailAddress,
            locale: state.configuration.locale
        )
        let response = try await StytchB2BClient.otp.email.authenticate(parameters: parameters)
        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
    }

    func emailDiscoveryAuthenticate(code: String) async throws {
        let emailAddress = MemberManager.emailAddress ?? ""

        let parameters = StytchB2BClient.OTP.Email.Discovery.AuthenticateParameters(
            code: code,
            emailAddress: emailAddress
        )
        let response = try await StytchB2BClient.otp.email.discovery.authenticate(parameters: parameters)
        DiscoveryManager.updateDiscoveredOrganizations(newDiscoveredOrganizations: response.discoveredOrganizations)
    }
}

struct EmailOTPEntryState {
    let configuration: StytchB2BUIClient.Configuration
    let didSendCode: Bool
}
