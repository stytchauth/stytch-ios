import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @State var shouldShowB2CUI: Bool = false
    @State var isAuthenticated: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isAuthenticated == true {
                    Text("You have logged in with Stytch!")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Button("Log Out") {
                        logOut()
                    }
                    .font(.title)
                    .bold()
                } else {
                    Button("Log In With Stytch!") {
                        shouldShowB2CUI = true
                    }
                    .font(.title)
                    .bold()
                }
            }
            .authenticationSheet(isPresented: $shouldShowB2CUI)
            .onOpenURL { url in
                shouldShowB2CUI = true
                let didHandle = StytchUIClient.handle(url: url)
                print("StytchUIClient didHandle: \(didHandle) - url: \(url)")
            }
            .task {
                for await _ in StytchUIClient.dismissUI.values {
                    shouldShowB2CUI = false
                }

                for await sessionInfo in StytchClient.sessions.onSessionChange.values {
                    switch sessionInfo {
                    case .available:
                        isAuthenticated = true
                    case .unavailable:
                        isAuthenticated = false
                    }
                }
            }
        }
    }

    func logOut() {
        Task {
            do {
                let response = try await StytchClient.sessions.revoke(parameters: .init(forceClear: true))
                print("log out response: \(response)")
            } catch {
                print("log out error: \(error.errorInfo)")
            }
        }
    }
}

#Preview {
    ContentView()
}
