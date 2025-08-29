import Combine
import StytchCore
import SwiftUI

enum OTPAuthenticationManagerErrors: Error {
    case ResendOTPError
}

@MainActor
public final class OTPAuthenticationManager: ObservableObject {
    @Published private(set) var didSendSMS = false
    @Published private(set) var didAuthenticateOTP = false

    var didAuthenticateOTPBinding: Binding<Bool> {
        Binding(
            get: { self.didAuthenticateOTP },
            set: { _ in }
        )
    }

    @Published var phoneNumber = ""
    private(set) var methodId: String = ""

    var hasUserAndSession: Bool {
        if StytchClient.sessions.session != nil, StytchClient.user.getSync() != nil {
            return true
        } else {
            return false
        }
    }

    func resendOTP() async throws {
        if didSendSMS {
            try await sendOTP(phoneNumber: phoneNumber)
        } else {
            throw OTPAuthenticationManagerErrors.ResendOTPError
        }
    }

    // Send a OTP via SMS
    func sendOTP(phoneNumber: String) async throws {
        let parameters = StytchClient.OTP.Parameters(deliveryMethod: .sms(phoneNumber: phoneNumber))
        let response = try await StytchClient.otps.send(parameters: parameters)
        methodId = response.methodId
        self.phoneNumber = phoneNumber
        didSendSMS = true
    }

    // Authenticate a user using the OTP sent via SMS
    func authenticateOTP(code: String) async throws {
        let parameters = StytchClient.OTP.AuthenticateParameters(code: code, methodId: methodId)
        _ = try await StytchClient.otps.authenticate(parameters: parameters)
        didAuthenticateOTP = true
    }
}
