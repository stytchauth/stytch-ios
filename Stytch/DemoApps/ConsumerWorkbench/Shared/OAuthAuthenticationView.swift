import StytchCore
import SwiftUI

struct OAuthAuthenticationView: View {
    let onAuth: (AuthenticateResponseType) -> Void
    @Environment(\.presentationMode) private var presentationMode
    @State private var confirmingThirdParty: Bool = false

    private var serverUrl: URL { configuration.serverUrl }

    var body: some View {
        Button("Authenticate with Apple") {
            Task {
                do {
                    let response = try await StytchClient.oauth.apple.start(parameters: .init())
                    print("User created: ", response.userCreated)
                    onAuth(response)
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print(error.errorInfo)
                }
            }
        }
        .padding()

        Button("Authenticate with Third Party") {
            confirmingThirdParty = true
        }
        .confirmationDialog(
            "Third Party",
            isPresented: $confirmingThirdParty,
            actions: {
                ForEach(Provider.allCases) { provider in
                    button(for: provider)
                }
            }
        )
        .padding()
    }

    private func button(for provider: Provider) -> some View {
        Button("\(provider.rawValue.capitalized)") {
            Task {
                do {
                    let (token, _) = try await provider.interface.start(
                        configuration: .init(
                            loginRedirectUrl: URL(string: "stytch-authentication://login")!,
                            signupRedirectUrl: URL(string: "stytch-authentication://signup")!
                        )
                    )
                    onAuth(try await StytchClient.oauth.authenticate(parameters: .init(token: token, sessionDuration: 10)))
                } catch {
                    print(error.errorInfo)
                }
            }
        }
    }
}

private enum Provider: String, CaseIterable, Identifiable {
    case amazon
    case facebook
    case figma
    case github
    case google
    case linkedin
    case salesforce
    case slack
    case snapchat
    case tiktok
    case twitter
    case yahoo

    var id: String {
        rawValue
    }

    var interface: StytchClient.OAuth.ThirdParty {
        switch self {
        case .amazon:
            return StytchClient.oauth.amazon
        case .facebook:
            return StytchClient.oauth.facebook
        case .figma:
            return StytchClient.oauth.figma
        case .github:
            return StytchClient.oauth.github
        case .google:
            return StytchClient.oauth.google
        case .linkedin:
            return StytchClient.oauth.linkedin
        case .salesforce:
            return StytchClient.oauth.salesforce
        case .slack:
            return StytchClient.oauth.slack
        case .snapchat:
            return StytchClient.oauth.snapchat
        case .tiktok:
            return StytchClient.oauth.tiktok
        case .twitter:
            return StytchClient.oauth.twitter
        case .yahoo:
            return StytchClient.oauth.yahoo
        }
    }
}
