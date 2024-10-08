import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    var config: StytchUIClient.Configuration
    @State private var isInitialized = false
    @State private var shouldPresentAuth = false
    @State private var sessionAndUser: (Session, User)?
    @State var subscriptions: Set<AnyCancellable> = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("You have logged in with Stytch!")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                Button("Log Out") {
                    logOut()
                }.font(.title).bold()
            }
            .padding()
            .authenticationSheet(isPresented: $shouldPresentAuth, onAuthCallback: { authenticateResponseType in
                print("user: \(authenticateResponseType.user) - session: \(authenticateResponseType.session)")
            }).onOpenURL { url in
                let didHandle = StytchUIClient.handle(url: url)
                print("StytchUIClient didHandle: \(didHandle) - url: \(url)")
            }
        }.task {
            StytchUIClient.configure(publicToken: "public-token", config: config)
            setUpObservations()
        }
    }

    func setUpObservations() {
        StytchClient.isInitialized.sink { isInitialized in
            let session = StytchClient.sessions.session
            let user = StytchClient.user.getSync()
            if let session, let user {
                sessionAndUser = (session, user)
                shouldPresentAuth = false
                print("we have a session and a user")
            } else {
                shouldPresentAuth = true
                print("we do not have a session and a user")
            }
            self.isInitialized = isInitialized
        }.store(in: &subscriptions)

        StytchClient.sessions.onSessionChange.sink { sessionInfo in
            switch sessionInfo {
            case let .available(session, lastValidatedAtDate):
                shouldPresentAuth = false
                print("we have a session")
            case .unavailable:
                shouldPresentAuth = true
                print("we do not have a session")
            }
        }.store(in: &subscriptions)
    }

    func logOut() {
        Task {
            do {
                let response = try await StytchClient.sessions.revoke()
                print("log out response: \(response)")
            } catch {
                print("log out error: \(error.errorInfo)")
            }
        }
    }
}

#Preview {
    ContentView(config: StytchUIDemoApp.realisticStytchUIConfig)
}
