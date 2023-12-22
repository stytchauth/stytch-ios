import Foundation
import StytchCore

protocol OTPCodeViewModelProtocol {
    func resendCode(phone: String) async throws
    func enterCode(code: String, methodId: String) async throws
}

final class OTPCodeViewModel {
    var state: OTPCodeState

    init(state: OTPCodeState) {
        self.state = state
    }
}

extension OTPCodeViewModel: OTPCodeViewModelProtocol {
    func resendCode(phone: String) async throws {
        let expiry = Date().addingTimeInterval(120)
        let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phone)))
        state = .init(
            config: state.config,
            phoneNumberE164: phone,
            formattedPhoneNumber: state.formattedPhoneNumber,
            methodId: result.methodId,
            codeExpiry: expiry
        )
    }
    
    func enterCode(code: String, methodId: String) async throws {
        _ = try await StytchClient.otps.authenticate(parameters: .init(code: code, methodId: methodId))
    }
}

struct OTPCodeState {
    let config: StytchUIClient.Configuration
    let phoneNumberE164: String
    let formattedPhoneNumber: String
    let methodId: String
    let codeExpiry: Date
}
