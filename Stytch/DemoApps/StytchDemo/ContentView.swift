import Combine
import StytchCore
import SwiftUI

struct ContentView: View {
    @State var isAuthenticated = false
    @State var subscriptions: Set<AnyCancellable> = []

    var body: some View {
        VStack {
            if isAuthenticated {
                LoggedInView()
            } else {
                OTPView()
            }
        }
        .onOpenURL { url in
            handle(url: url)
        }
        .task {
            StytchClient.configure(publicToken: "your-public-token")
            setUpObservations()
        }
    }

    func setUpObservations() {
        StytchClient.sessions.onAuthChange.sink { token in
            if token == nil {
                isAuthenticated = false
            } else {
                isAuthenticated = true
            }
        }.store(in: &subscriptions)
    }

    func handle(url: URL) {
        Task {
            do {
                switch try await StytchClient.handle(url: url, sessionDuration: 5) {
                case let .handled(response):
                    print("handled: \(response.session) - \(response.user)")
                case .notHandled:
                    print("not handled")
                case let .manualHandlingRequired(tokenType, token):
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
