import StytchCore
import SwiftUI

@main
struct StytchDemoApp: App {
    @State var session: Session?

    private let hostUrl = URL(string: "https://dan-stytch.github.io")!

    var body: some Scene {
        WindowGroup {
            ContentView(hostUrl: hostUrl, session: session)
                .onAppear {
                    StytchClient.configure(
                        publicToken: "public-token-test-9e306f84-4f6a-4c23-bbae-abd27bcb90ba", // TODO: extract this token
                        hostUrl: self.hostUrl
                    )
                }
                .onOpenURL { url in
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
                    guard let token = components.queryItems?.first(where: { $0.name == "token" })?.value else { return }
                    Task {
                        do {
                            let resp = try await StytchClient.magicLinks.authenticate(
                                parameters: .init(token: token, sessionDuration: .init(rawValue: 30))
                            )
                            self.session = resp.session
                        }
                    }
                }
        }
    }
}
