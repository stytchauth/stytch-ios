import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    var configuration: StytchB2BUIClient.Configuration
    @State private var shouldPresentAuth = false
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
            .b2bAuthenticationSheet(isPresented: $shouldPresentAuth, onB2BAuthCallback: { authenticateResponseType in
                print("user: \(authenticateResponseType.user) - session: \(authenticateResponseType.session)")
            }).onOpenURL { url in
                let didHandle = StytchB2BUIClient.handle(url: url)
                print("StytchUIClient didHandle: \(didHandle) - url: \(url)")
            }
        }.task {
            StytchB2BUIClient.configure(configuration: configuration)
            setUpObservations()
        }
    }

    func setUpObservations() {
        StytchB2BClient.sessions.onMemberSessionChange.sink { sessionInfo in
            switch sessionInfo {
            case let .available(session, lastValidatedAtDate):
                print("Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                shouldPresentAuth = false
            case .unavailable:
                print("Session Unavailable\n")
                shouldPresentAuth = true
            }
        }.store(in: &subscriptions)
    }

    func logOut() {
        Task {
            do {
                let response = try await StytchB2BClient.sessions.revoke()
                print("log out response: \(response)")
            } catch {
                print("log out error: \(error.errorInfo)")
            }
        }
    }
}

#Preview {
    ContentView(configuration: StytchB2BUIDemoApp.realisticStytchUIConfig)
}
