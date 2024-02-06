import Foundation
import StytchCore

protocol OTPCodeViewModelProtocol {
    func resendCode(input: String) async throws
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
    func resendCode(input: String) async throws {
        let expiry = Date().addingTimeInterval(120)
        let result: StytchClient.OTP.OTPResponse
        switch state.otpMethod {
        case .sms:
            result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: input)))
        case .email:
            result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .email(email: input, loginTemplateId: state.config.otp?.loginTemplateId, signupTemplateId: state.config.otp?.signupTemplateId)))
        case .whatsapp:
            result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .whatsapp(phoneNumber: input)))
        }
        state = .init(
            config: state.config,
            otpMethod: state.otpMethod,
            input: input,
            formattedInput: state.formattedInput,
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
    let otpMethod: StytchUIClient.Configuration.OTPMethod
    let input: String
    let formattedInput: String
    let methodId: String
    let codeExpiry: Date
}
