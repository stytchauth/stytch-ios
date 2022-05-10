import StytchCore
import SwiftUI

@main
struct StytchDemoApp: App {
    @State var session: Session?

    private let hostUrl = URL(string: "https://dan-stytch.github.io")!

    var body: some Scene {
        WindowGroup {
            ContentView(hostUrl: hostUrl, session: session) { session = nil }
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
                .onOpenURL { url in
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
    }
}
