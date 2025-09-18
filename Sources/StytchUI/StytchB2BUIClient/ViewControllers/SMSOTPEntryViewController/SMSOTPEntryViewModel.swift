import Foundation
import StytchCore

final class SMSOTPEntryViewModel {
    let state: SMSOTPEntryState

    init(
        state: SMSOTPEntryState
    ) {
        self.state = state
    }

    func smsAuthenticate(code: String) async throws {
        guard let organizationId = OrganizationManager.organizationId else {
            throw StytchSDKError.noOrganziationId
        }

        guard let memberId = MemberManager.memberId else {
            throw StytchSDKError.noMemberId
        }

        let parameters = StytchB2BClient.OTP.SMS.AuthenticateParameters(
            organizationId: organizationId,
            memberId: memberId,
            code: code,
            setMfaEnrollment: nil
        )
        let response = try await StytchB2BClient.otp.sms.authenticate(parameters: parameters)
        B2BAuthenticationManager.handleSecondaryReponse(b2bAuthenticateResponse: response)
    }
}

struct SMSOTPEntryState {
    let configuration: StytchB2BUIClient.Configuration
    let didSendCode: Bool
}
