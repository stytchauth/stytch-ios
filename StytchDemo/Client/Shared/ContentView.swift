import StytchCore
import SwiftUI

struct ContentView: View {
    let serverUrl: URL
    var sessionUser: (Session, User)?
    let logOutTapped: () -> Void
    let onAuth: (Session, User) -> Void

    var body: some View {
        NavigationView {
            if let sessionUser = sessionUser {
                VStack(spacing: 12) {
                    Spacer()
                    Text("Welcome, \(sessionUser.1.name.firstName.presence ?? "pal")!")
                        .font(.title)
                    Spacer()
                    NavigationLink("View session info") {
                        SessionView(sessionUser: sessionUser)
                    }
                    NavigationLink("Authenticate further (or refresh factor)") {
                        AuthenticationOptionsView(session: sessionUser.0, onAuth: onAuth)
                    }
                    Spacer()
                }
                .navigationTitle("Stytch Demo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Log out", action: logOutTapped)
                    }
                }
            } else {
                AuthenticationOptionsView(session: sessionUser?.0, onAuth: onAuth)
                    .navigationTitle("Stytch Demo")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next force_unwrapping
        ContentView(serverUrl: URL(string: "https://stytch.com")!, sessionUser: nil) {} onAuth: { _, _ in }
    }
}

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

extension Optional where Wrapped == String {
    var presence: String? {
        flatMap(\.presence)
    }
}

extension String {
    var presence: String? {
        isEmpty ? nil : self
    }
}
