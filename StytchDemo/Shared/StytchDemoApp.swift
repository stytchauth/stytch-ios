import StytchCore
import SwiftUI

@main
struct StytchDemoApp: App {
    @State var session: Session?

    private let hostUrl = URL(string: "https://dan-stytch.github.io")!

    var body: some Scene {
        WindowGroup {
            ContentView(hostUrl: hostUrl, session: session) {
                Task {
                    _ = try await StytchClient.sessions.revoke()
                    session = nil
                }
            }
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
                } catch {}
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                guard let url = userActivity.webpageURL else { return }
                handle(url: url)
            }
            .onOpenURL(perform: handle(url:))
            .handlesExternalEvents(preferring: [], allowing: ["*"])
        }
        .commands {
            CommandGroup(replacing: .newItem, addition: { })
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }

    private func handle(url: URL) {
        Task {
            do {
                switch try await StytchClient.handle(url: url) {
                case let .handled((resp, _)):
                    self.session = resp.session
                case .notHandled:
                    print("not handled")
                }
            }
        }
    }
}
