import Foundation
import StytchCore

protocol OTPCodeViewModelProtocol {
    func resendCode(phone: String) async throws
    func enterCode(code: String, methodId: String) async throws
}

final class OTPCodeViewModel {
    var state: OTPCodeState
    var otpClient: OTPProtocol

    init(state: OTPCodeState, otpClient: OTPProtocol = StytchClient.otps) {
        self.state = state
        self.otpClient = otpClient
    }
}

extension OTPCodeViewModel: OTPCodeViewModelProtocol {
    func resendCode(phone: String) async throws {
        let expiry = Date().addingTimeInterval(120)
        let result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone)))
        state = .init(
            config: state.config,
            phoneNumberE164: phone,
            formattedPhoneNumber: state.formattedPhoneNumber,
            methodId: result.methodId,
            codeExpiry: expiry
        )
    }

    func enterCode(code: String, methodId: String) async throws {
        let response = try await otpClient.authenticate(parameters: .init(code: code, methodId: methodId))
        StytchUIClient.onAuthCallback?(response)
    }
}

struct OTPCodeState {
    let config: StytchUIClient.Configuration
    let phoneNumberE164: String
    let formattedPhoneNumber: String
    let methodId: String
    let codeExpiry: Date
}
