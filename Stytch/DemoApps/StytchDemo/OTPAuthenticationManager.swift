import Combine
import StytchCore
import SwiftUI

enum OTPAuthenticationManagerErrors: Error {
    case ResendOTPError
}

public class OTPAuthenticationManager: ObservableObject {
    @Published var didSendSMS = false
    @Published var didAuthenticateOTP = false

    var didAuthenticateOTPBinding: Binding<Bool> {
        Binding(
            get: { self.didAuthenticateOTP },
            set: { _ in }
        )
    }

    var phoneNumber = ""
    var methodId: String = ""

    var hasUserAndSession: Bool {
        if StytchClient.sessions.session != nil, StytchClient.user.getSync() != nil {
            return true
        } else {
            return false
        }
    }

    func resendOTP() async throws {
        if didSendSMS == true {
            try await sendOTP(phoneNumber: phoneNumber)
        } else {
            throw OTPAuthenticationManagerErrors.ResendOTPError
        }
    }

    // Send a OTP (one time passcode) via SMS
    func sendOTP(phoneNumber: String) async throws {
        let parameters = StytchClient.OTP.Parameters(deliveryMethod: .sms(phoneNumber: phoneNumber))
        let response = try await StytchClient.otps.loginOrCreate(parameters: parameters)
        // save the methodId for the subsequent authenticate call
        methodId = response.methodId
        self.phoneNumber = phoneNumber
        DispatchQueue.main.async { [weak self] in
            self?.didSendSMS = true
        }
    }

    // Authenticate a user using the OTP sent via SMS
    func authenticateOTP(code: String) async throws {
        let parameters = StytchClient.OTP.AuthenticateParameters(code: code, methodId: methodId)
        _ = try await StytchClient.otps.authenticate(parameters: parameters)
        DispatchQueue.main.async { [weak self] in
            self?.didAuthenticateOTP = true
        }
    }

    func getAlotOfTelemetrtIds() {
        Task {
            do {
                for index in 0..<100 {
                    print("getTelemetryID about to be called \(index)")
                    let telemetryID = try await StytchClient.dfp.getTelemetryID()
                    print("telemetryID: \(telemetryID)")
                    print("--------------------------------------------")
                }
            } catch {
                print(error.errorInfo)
            }
        }
    }
}
