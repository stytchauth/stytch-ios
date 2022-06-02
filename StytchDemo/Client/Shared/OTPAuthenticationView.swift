import StytchCore
import SwiftUI

struct OTPAuthenticationView: View {
    let session: Session?
    let onAuth: (Session, User) -> Void

    @State private var deliveryMethod: DeliveryMethod = .sms
    @State private var deliveryMethodValue: String = ""
    @State private var isLoading = false
    @State private var methodId = ""
    @State private var otp = ""

    enum DeliveryMethod: String, Hashable, CaseIterable {
        case sms
        case whatsapp
        case email

        var title: String {
            switch self {
            case .sms: return "SMS"
            case .whatsapp: return "WhatsApp"
            case .email: return "Email"
            }
        }

        var label: String {
            switch self {
            case .sms, .whatsapp: return "Phone Number"
            case .email: return "Email"
            }
        }

        #if !os(macOS)
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
        #endif

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
                    ForEach(DeliveryMethod.allCases, id: \.self) { Text($0.title).tag($0) }
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
            .disabled(isLoading || deliveryMethodHasRecentAuth || deliveryMethodValue.isEmpty)
            .padding()

            Spacer()
        }
    }

    var deliveryMethodHasRecentAuth: Bool {
        guard let session = session else {
            return false
        }

        // If the delivery method has authenticated in the last 3 minutes, it has recent auth
        return session.authenticationFactors
            .filter { $0.kind == .otp && $0.matches(deliveryMethod) }
            .contains {
                $0.lastAuthenticatedAt > Date().addingTimeInterval(-180)
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
                let response = try await StytchClient.otps.authenticate(parameters: params)
                onAuth(response.session, response.user)
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}

private extension Session.AuthenticationFactor {
    func matches(_ deliveryMethod: OTPAuthenticationView.DeliveryMethod) -> Bool {
        switch self.deliveryMethod {
        case .email: return deliveryMethod == .email
        case .sms: return deliveryMethod == .sms
        case .whatsapp: return deliveryMethod == .whatsapp
        default: return false
        }
    }
}
