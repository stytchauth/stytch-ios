import Combine
import StytchCore
import SwiftUI

struct ContentView: View {
    @State var hasSession = false
    @State var hasUser = false
    @State var subscriptions: Set<AnyCancellable> = []

    var body: some View {
        VStack {
            if hasSession, hasUser {
                LoggedInView()
            } else {
                OTPView()
            }
        }
        .onOpenURL { url in
            handle(url: url)
        }
        .task {
            // Set up your observations before calling configure
            setUpObservations()

            // configure the StytchClient
            let stytchClientConfiguration = StytchClientConfiguration(publicToken: "your-public-token", defaultSessionDuration: 5)
            StytchClient.configure(configuration: stytchClientConfiguration)
        }
    }

    func setUpObservations() {
        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink { sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    print("Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                    hasSession = true
                case .unavailable:
                    print("Session Unavailable\n")
                    hasSession = false
                }
            }.store(in: &subscriptions)

        StytchClient.user.onUserChange
            .receive(on: DispatchQueue.main)
            .sink { userInfo in
                switch userInfo {
                case let .available(user, lastValidatedAtDate):
                    print("User Available: \(user.name) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                    hasUser = true
                case .unavailable:
                    print("User Unavailable\n")
                    hasUser = false
                }
            }.store(in: &subscriptions)

        StytchClient.isInitialized
            .receive(on: DispatchQueue.main)
            .sink { isInitialized in
                print("StytchClient.isInitialized: \(isInitialized)\n")
            }.store(in: &subscriptions)
    }

    func handle(url: URL) {
        Task {
            do {
                switch try await StytchClient.handle(url: url, sessionDurationMinutes: 5) {
                case let .handled(responseData):
                    switch responseData {
                    case let .auth(response):
                        print("handled auth: \(response.session) - \(response.user)")
                    case let .oauth(response):
                        print("handled oauth: \(response.session) - \(response.user)")
                    }
                case .notHandled:
                    print("not handled")
                case let .manualHandlingRequired(tokenType, _, token):
                    print("manualHandlingRequired: tokenType: \(tokenType) - token: \(token)")
                }
            } catch {
                print("handle url error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
