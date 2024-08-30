import StytchCore
import StytchUI
import SwiftUI

struct Configuration {
    let publicToken = "your-public-token-here"
    let serverUrl = URL(string: "http://example.com")!
}

let configuration = Configuration()

@main
struct StytchApp: App {
    @State private var sessionUser: (Session, User)?
    @State private var errorAlertPresented = false
    @State private var errorMessage = ""
    @State private var resetPasswordToken: ResetPasswordToken?

    var body: some Scene {
        WindowGroup {
            ContentView(sessionUser: sessionUser) {
                Task {
                    _ = try await StytchClient.sessions.revoke()
                    sessionUser = nil
                }
            } onAuth: { sessionUser = ($0.session, $0.user) }
                .padding()
                .frame(minHeight: 250)
                .task {
                    if configuration.publicToken.hasPrefix("public-token") == true {
                        StytchClient.configure(publicToken: configuration.publicToken)
                    } else {
                        fatalError("Add you public token above.")
                    }
                }
                // Handle web-browsing deeplinks (enables universal links on macOS)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else { return }
                    handle(url: url)
                }
                // Handle deeplinks
                .onOpenURL { url in
                    handle(url: url)
                }
                // Prevent deeplink from opening new window
                .handlesExternalEvents(preferring: [], allowing: ["*"])
                .sheet(item: $resetPasswordToken, onDismiss: nil) { wrapped in
                    ResetPasswordView(token: wrapped.token) { response in
                        sessionUser = (response.session, response.user)
                        resetPasswordToken = nil
                    }
                }
                .alert("🚨 Error 🚨", isPresented: $errorAlertPresented, actions: { EmptyView() }, message: { Text(errorMessage) })
        }
        // Prevent user from being able to create a new window
        .commands { CommandGroup(replacing: .newItem, addition: {}) }
        // Prevent deeplink from opening new window
        .handlesExternalEvents(matching: ["*"])
    }

    private func handle(url: URL) {
        Task {
            do {
                switch try await StytchClient.handle(url: url, sessionDuration: 5) {
                case let .handled(response):
                    print("handled: \(response.session) - \(response.user)")
                    self.sessionUser = (response.session, response.user)
                case .notHandled:
                    print("not handled")
                case let .manualHandlingRequired(tokenType, token):
                    print("manualHandlingRequired: tokenType: \(tokenType) - token: \(token)")
                    if tokenType == .passwordReset {
                        self.resetPasswordToken = .init(token: token)
                    } else {
                        // handle other token types here
                    }
                }
            } catch {
                print("handle url error: \(error)")
                switch error {
                case let error as StytchError:
                    errorMessage = error.message
                    errorAlertPresented = true
                default:
                    break
                }
            }
        }
    }

    struct ResetPasswordToken: Identifiable {
        let id: UUID = .init()
        let token: String
    }
}
