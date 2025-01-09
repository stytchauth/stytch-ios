import StytchCore
import SwiftUI

struct OTPView: View {
    @State var textFieldText: String = "Enter Your Phone Number"
    @State var inputText: String = ""
    @State var showAlert = false
    @State var errorMessage = ""
    @StateObject var otpAuthenticationManager = OTPAuthenticationManager()

    var body: some View {
        VStack {
            Text("You are currently logged out.")
                .font(.headline)
                .bold()
                .multilineTextAlignment(.center)

            Text("Log in with Stytch!")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            TextField(textFieldText, text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()

            HStack {
                let height = 40.0

                Button("Submit") {
                    if otpAuthenticationManager.didSendSMS == false {
                        send()
                    } else {
                        authenticateOTP()
                    }
                }
                .padding()
                .frame(height: height)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Resend") {
                    resend()
                }
                .padding()
                .frame(height: height)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            Button("Generate Alot of Telemtery Ids") {
                otpAuthenticationManager.getAlotOfTelemetrtIds()
            }
            .padding()
            .frame(height: 40.0)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                showAlert = false
            }
        } message: {
            Text(errorMessage)
        }
    }

    func send() {
        Task {
            do {
                try await otpAuthenticationManager.sendOTP(phoneNumber: "+1\(inputText)")
                textFieldText = "Enter The One Time Code"
                inputText = ""
            } catch {
                print(error.errorInfo)
                showErrorAlert(error)
            }
        }
    }

    func resend() {
        Task {
            do {
                try await otpAuthenticationManager.resendOTP()
                textFieldText = "Enter The One Time Code"
                inputText = ""
            } catch {
                print(error.errorInfo)
                showErrorAlert(error)
            }
        }
    }

    func authenticateOTP() {
        Task {
            do {
                try await otpAuthenticationManager.authenticateOTP(code: inputText)
            } catch {
                print(error.errorInfo)
                showErrorAlert(error)
            }
        }
    }

    func showErrorAlert(_ error: Error) {
        inputText = ""
        showAlert = true
        errorMessage = error.errorInfo
    }
}

#Preview {
    OTPView()
}
