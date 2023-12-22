import Foundation
import StytchCore

protocol OTPCodeViewModelDelegate {
    func showInvalidCode()
}

protocol OTPCodeViewModelProtocol {
    func resendCode(phone: String) async throws
    func enterCode(code: String, methodId: String) async throws
}

final class OTPCodeViewModel {
    var state: OTPCodeState
    let delegate: OTPCodeViewModelDelegate

    init(state: OTPCodeState, delegate: OTPCodeViewModelDelegate) {
        self.state = state
        self.delegate = delegate
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
        do {
            _ = try await StytchClient.otps.authenticate(parameters: .init(code: code, methodId: methodId))
        } catch let error as StytchError where error.errorType == "otp_code_not_found" {
            DispatchQueue.main.async {
                self.delegate.showInvalidCode()
            }
        } catch {
            throw error
        }
    }
    
}

struct OTPCodeState {
    let config: StytchUIClient.Configuration
    let phoneNumberE164: String
    let formattedPhoneNumber: String
    let methodId: String
    let codeExpiry: Date
}
