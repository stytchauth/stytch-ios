import StytchCore
import SwiftUI

struct ContentView: View {
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
                    NavigationLink("View hobbies") {
                        HobbiesView()
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                    #if os(macOS)
                    Button("Log out", action: logOutTapped)
                        .padding()
                    #endif
                }
                .navigationTitle("Stytch Demo")
                #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Log out", action: logOutTapped)
                    }
                }
                #endif
            } else {
                AuthenticationOptionsView(session: sessionUser?.0, onAuth: onAuth)
                    .navigationTitle("Stytch Demo")
                    #if !os(macOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
            }
        }
    }
}
