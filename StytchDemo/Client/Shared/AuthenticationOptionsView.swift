import SwiftUI
import StytchCore

struct AuthenticationOptionsView: View {
    let session: Session?
    let onAuth: (Session, User) -> Void
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            NavigationLink("Authenticate with Email") { EmailAuthenticationView() }
                .padding()
            NavigationLink("Authenticate with OTP") {
                OTPAuthenticationView(session: session) {
                    onAuth($0, $1)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
    }
}
