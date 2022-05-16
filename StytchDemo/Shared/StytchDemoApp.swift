import StytchCore
import SwiftUI

@main
struct StytchDemoApp: App {
    private let hostUrl = URL(string: "https://dan-stytch.github.io")!

    @State private var session: Session?
    @State private var errorAlertPresented = false
    @State private var errorMessage = ""

    var body: some Scene {
        WindowGroup {
            ContentView(hostUrl: hostUrl, session: session) {
                Task {
                    _ = try await StytchClient.sessions.revoke()
                    session = nil
                }
            } onAuth: { session = $0 }
                .padding()
                .frame(minHeight: 250)
                .task {
                    StytchClient.configure(
                        publicToken: "public-token-test-9e306f84-4f6a-4c23-bbae-abd27bcb90ba", // TODO: extract this token
                        hostUrl: hostUrl
                    )
                    do {
                        let response = try await StytchClient.sessions.authenticate(parameters: .init(duration: 30))
                        switch response {
                        case let .authenticated(response):
                            session = response.session
                        case .unauthenticated:
                            break
                        }
                    } catch {
                        handle(error: error)
                    }
                }
                // Handle web-browsing deeplinks (enables universal links on macOS)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else { return }
                    handle(url: url)
                }
                // Handle deeplinks
                .onOpenURL(perform: handle(url:))
                // Prevent deeplink from opening new window
                .handlesExternalEvents(preferring: [], allowing: ["*"])
                .alert("🚨 Error 🚨", isPresented: $errorAlertPresented, actions: { EmptyView() }, message: { Text(errorMessage) })
        }
        // Prevent user from being able to create a new window
        .commands { CommandGroup(replacing: .newItem, addition: {}) }
        // Prevent deeplink from opening new window
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }

    private func handle(url: URL) {
        Task {
            do {
                switch try await StytchClient.handle(url: url) {
                case let .handled(response):
                    self.session = response.session
                case .notHandled:
                    print("not handled")
                }
            } catch {
                handle(error: error)
            }
        }
    }

    private func handle(error: Error) {
        switch error {
        case let error as StytchStructuredError:
            errorMessage = error.message
            errorAlertPresented = true
        case let error as StytchGenericError:
            errorMessage = error.message
            errorAlertPresented = true
        default:
            break
        }
    }
}
