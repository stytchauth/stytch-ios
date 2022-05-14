import StytchCore
import SwiftUI

struct OTPAuthenticationView: View {
    let hostUrl: URL
    let onAuth: (Session) -> Void

    @State private var deliveryMethod: DeliveryMethod = .sms
    @State private var deliveryMethodValue: String = ""
    @State private var isLoading = false
    @State private var methodId = ""
    @State private var otp = ""

    enum DeliveryMethod: Hashable {
        case email
        case sms
        case whatsapp

        var label: String {
            switch self {
            case .sms, .whatsapp: return "Phone Number"
            case .email: return "Email"
            }
        }

        var contentType: UITextContentType {
            switch self {
            case .sms, .whatsapp: return .telephoneNumber
            case .email: return .emailAddress
            }
        }

        var keyboardType: UIKeyboardType {
            switch self {
            case .sms, .whatsapp: return .phonePad
            case .email: return .emailAddress
            }
        }

        func deliveryMethod(_ value: String) -> StytchClient.OneTimePasscodes.LoginOrCreateParameters.DeliveryMethod {
            let normalizedPhone: () -> String = { "+1" + value.filter(\.isNumber) }
            switch self {
            case .whatsapp:
                return .whatsapp(phoneNumber: normalizedPhone())
            case .sms:
                return .sms(phoneNumber: normalizedPhone())
            case .email:
                return .email(value)
            }
        }
    }

    var body: some View {
        VStack {
            Picker(
                selection: $deliveryMethod,
                content: {
                    Text("SMS")
                        .tag(DeliveryMethod.sms)
                    Text("Email")
                        .tag(DeliveryMethod.email)
                    Text("WhatsApp")
                        .tag(DeliveryMethod.whatsapp)
                },
                label: { Text("Delivery Method") }
            )
            .pickerStyle(.segmented)

            Spacer()

            if methodId.isEmpty {
                TextField(text: $deliveryMethodValue, label: { Text(deliveryMethod.label) })
                    .onSubmit(login)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(deliveryMethod.keyboardType)
                    .textContentType(deliveryMethod.contentType)
                #endif
            } else {
                TextField(text: $otp, label: { Text("One-time Code") })
                    .onSubmit(authenticate)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.phonePad)
                    .textContentType(.oneTimeCode)
                #endif
            }

            Button(action: methodId.isEmpty ? login : authenticate, label: {
                if isLoading {
                    ZStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Authenticate").hidden()
                    }
                } else {
                    Text(methodId.isEmpty ? "Authenticate" : "Submit Code")
                }
            })
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || deliveryMethodValue.isEmpty)
            .padding()

            Spacer()
        }
    }

    func login() {
        isLoading = true
        Task {
            let otpParams: StytchClient.OneTimePasscodes.LoginOrCreateParameters = .init(
                deliveryMethod: deliveryMethod.deliveryMethod(deliveryMethodValue)
            )
            do {
                let response = try await StytchClient.otps.loginOrCreate(parameters: otpParams)
                methodId = response.methodId
            } catch {
                print(error)
            }
            isLoading = false
        }
    }

    func authenticate() {
        isLoading = true
        Task {
            let params: StytchClient.OneTimePasscodes.AuthenticateParameters = .init(code: otp, methodId: methodId, sessionDuration: 30)
            do {
                let sessionResp = try await StytchClient.otps.authenticate(parameters: params)
                onAuth(sessionResp.session)
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}
