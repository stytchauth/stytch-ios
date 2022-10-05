import StytchCore
import SwiftUI

struct OAuthAuthenticationView: View {
    let onAuth: (Session, User) -> Void
    @Environment(\.presentationMode) private var presentationMode

    private var serverUrl: URL { configuration.serverUrl }

    var body: some View {
        Button("Authenticate with Apple") {
            Task {
                do {
                    let resp = try await StytchClient.oauth.apple.start(parameters: .init())
                    onAuth(resp.session, resp.user)
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print(error)
                }
            }
        }
        .padding()

        ForEach(Provider.allCases) { provider in
            button(for: provider)
        }
        .padding()
    }

    private func button(for provider: Provider) -> some View {
        Button("Authenticate with \(provider.rawValue.capitalized)") {
            do {
                try provider.interface.start(
                    parameters: .init(loginRedirectUrl: serverUrl, signupRedirectUrl: serverUrl)
                )
            } catch {
                print(error)
            }
        }
    }
}

private enum Provider: String, CaseIterable, Identifiable {
    case amazon
    case facebook
    case github
    case google
    case linkedin
    case slack

    var id: String {
        rawValue
    }

    var interface: StytchClient.OAuth.ThirdPartyProvider {
        switch self {
        case .amazon:
            return StytchClient.oauth.amazon
        case .facebook:
            return StytchClient.oauth.facebook
        case .github:
            return StytchClient.oauth.github
        case .google:
            return StytchClient.oauth.google
        case .linkedin:
            return StytchClient.oauth.linkedin
        case .slack:
            return StytchClient.oauth.slack
        }
    }
}
