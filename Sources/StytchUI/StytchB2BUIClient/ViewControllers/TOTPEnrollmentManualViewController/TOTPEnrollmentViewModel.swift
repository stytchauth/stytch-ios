import StytchCore

final class TOTPEnrollmentViewModel {
    let state: TOTPEnrollmentState

    init(
        state: TOTPEnrollmentState
    ) {
        self.state = state
    }

    func createTOTP() async throws -> String {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        guard let memberId = MemberManager.memberId else {
            throw StytchSDKError.noMemberId
        }

        let parameters = StytchB2BClient.TOTP.CreateParameters(organizationId: organizationId, memberId: memberId, expirationMinutes: 30)
        let response = try await StytchB2BClient.totp.create(parameters: parameters)
        B2BAuthenticationManager.handleTOTPResponse(totpResponse: response.wrapped)
        return response.wrapped.secret
    }
}

struct TOTPEnrollmentState {
    let configuration: StytchB2BUIClient.Configuration
}
