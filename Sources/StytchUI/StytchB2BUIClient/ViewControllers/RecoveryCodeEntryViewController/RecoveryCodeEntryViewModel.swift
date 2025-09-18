import StytchCore

final class RecoveryCodeEntryViewModel {
    let state: RecoveryCodeEntryState

    init(
        state: RecoveryCodeEntryState
    ) {
        self.state = state
    }

    func recover(recoveryCode: String) async throws {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        guard let memberId = MemberManager.memberId else {
            throw StytchSDKError.noMemberId
        }

        let parameters = StytchB2BClient.RecoveryCodes.RecoveryCodesRecoverParameters(
            organizationId: organizationId,
            memberId: memberId,
            recoveryCode: recoveryCode
        )
        let response = try await StytchB2BClient.recoveryCodes.recover(parameters: parameters)
        B2BAuthenticationManager.handleSecondaryReponse(b2bAuthenticateResponse: response)
    }
}

struct RecoveryCodeEntryState {
    let configuration: StytchB2BUIClient.Configuration
}
