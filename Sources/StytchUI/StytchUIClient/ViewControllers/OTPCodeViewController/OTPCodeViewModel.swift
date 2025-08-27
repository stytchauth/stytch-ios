import Foundation
import StytchCore

protocol OTPCodeViewModelProtocol {
    func forgotPassword(email: String) async throws
    func resendCode(input: String) async throws
    func enterCode(code: String, methodId: String) async throws
}

final class OTPCodeViewModel {
    var state: OTPCodeState
    let otpClient: OTPProtocol
    let passwordClient: PasswordsProtocol

    init(state: OTPCodeState, otpClient: OTPProtocol = StytchClient.otps, passwordClient: PasswordsProtocol = StytchClient.passwords) {
        self.state = state
        self.otpClient = otpClient
        self.passwordClient = passwordClient
    }
}

extension OTPCodeViewModel: OTPCodeViewModelProtocol {
    func forgotPassword(email: String) async throws {
        guard state.config.supportsPasswords else { return }
        let password = state.config.passwordOptions
        StytchUIClient.pendingResetEmail = email
        let params = params(email: email, password: password)
        _ = try await passwordClient.resetByEmailStart(parameters: params)
        try? await EventsClient.logEvent(parameters: .init(eventName: "email_sent", details: ["email": email, "type": "reset_password"]))
    }

    func resendCode(input: String) async throws {
        let expiry = Date().addingTimeInterval(120)
        let result: StytchClient.OTP.OTPResponse
        switch state.otpMethod {
        case .sms:
            result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: input)))
        case .email:
            result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .email(email: input, loginTemplateId: state.config.otpOptions?.loginTemplateId, signupTemplateId: state.config.otpOptions?.signupTemplateId)))
        case .whatsapp:
            result = try await otpClient.loginOrCreate(parameters: .init(deliveryMethod: .whatsapp(phoneNumber: input)))
        }
        try? await EventsClient.logEvent(parameters: .init(eventName: "email_sent", details: ["email": input, "type": "login_or_create_otp"]))
        state = .init(
            config: state.config,
            otpMethod: state.otpMethod,
            input: input,
            formattedInput: state.formattedInput,
            methodId: result.methodId,
            codeExpiry: expiry,
            passwordsEnabled: state.passwordsEnabled
        )
    }

    func enterCode(code: String, methodId: String) async throws {
        _ = try await otpClient.authenticate(parameters: .init(code: code, methodId: methodId))
    }
}

struct OTPCodeState {
    let config: StytchUIClient.Configuration
    let otpMethod: StytchUIClient.OTPMethod
    let input: String
    let formattedInput: String
    let methodId: String
    let codeExpiry: Date
    let passwordsEnabled: Bool
}

extension OTPCodeViewModel {
    func params(email: String, password: StytchUIClient.PasswordOptions?) -> StytchClient.Passwords.ResetByEmailStartParameters {
        .init(
            email: email,
            loginRedirectUrl: state.config.redirectUrl,
            loginExpirationMinutes: password?.loginExpiration,
            resetPasswordRedirectUrl: state.config.redirectUrl,
            resetPasswordExpirationMinutes: password?.resetPasswordExpiration,
            resetPasswordTemplateId: password?.resetPasswordTemplateId,
            locale: state.config.locale
        )
    }
}
