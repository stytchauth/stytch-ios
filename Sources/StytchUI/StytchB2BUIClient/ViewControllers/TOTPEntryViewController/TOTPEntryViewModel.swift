import StytchCore

final class TOTPEntryViewModel {
    let state: TOTPEntryState

    init(
        state: TOTPEntryState
    ) {
        self.state = state
    }

    func authenticateTOTP(code: String) async throws {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        guard let memberId = MemberManager.memberId else {
            throw StytchSDKError.noMemberId
        }

        let parameters = StytchB2BClient.TOTP.AuthenticateParameters(
            organizationId: organizationId,
            memberId: memberId,
            code: code,
            setMfaEnrollment: .enroll,
            setDefaultMfa: true
        )
        let response = try await StytchB2BClient.totp.authenticate(parameters: parameters)
        B2BAuthenticationManager.handleSecondaryReponse(b2bAuthenticateResponse: response)
    }
}

struct TOTPEntryState {
    let configuration: StytchB2BUIClient.Configuration
}
