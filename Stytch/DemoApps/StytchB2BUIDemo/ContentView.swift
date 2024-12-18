import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isAuthenticated {
                Button("Log Out") {
                    logOut()
                }.font(.title).bold()
            } else {
                Button("Show No MFA") {
                    viewModel.showNoMFA = true
                }.font(.title).bold()
                    .b2bAuthenticationSheet(configuration: Self.noMFAStytchB2BUIConfig, isPresented: $viewModel.showNoMFA, onB2BAuthCallback: {
                        print("member session: \(String(describing: StytchB2BClient.sessions.memberSession))")
                    })

                Button("Show MFA") {
                    viewModel.showMFA = true
                }.font(.title).bold()
                    .b2bAuthenticationSheet(configuration: Self.mfaRequiredStytchB2BUIConfig, isPresented: $viewModel.showMFA, onB2BAuthCallback: {
                        print("member session: \(String(describing: StytchB2BClient.sessions.memberSession))")
                    })

                Button("Show Discovery") {
                    viewModel.showDiscovery = true
                }.font(.title).bold()
                    .b2bAuthenticationSheet(configuration: Self.discoveryStytchB2BUIConfig, isPresented: $viewModel.showDiscovery, onB2BAuthCallback: {
                        print("member session: \(String(describing: StytchB2BClient.sessions.memberSession))")
                    })
            }
        }
        .padding()
        .onOpenURL { url in
            let didHandle = StytchB2BUIClient.handle(url: url)
            print("StytchUIClient didHandle: \(didHandle) - url: \(url)")
        }
    }

    func logOut() {
        Task {
            do {
                let response = try await StytchB2BClient.sessions.revoke(parameters: .init(forceClear: true))
                print("log out response: \(response)")
            } catch {
                print("log out error: \(error.errorInfo)")
            }
        }
    }
}

class ContentViewModel: ObservableObject {
    @Published var showNoMFA: Bool = false
    @Published var showMFA: Bool = false
    @Published var showDiscovery: Bool = false
    @Published var isAuthenticated: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        StytchB2BUIClient.dismissUI
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.showNoMFA = false
                self?.showMFA = false
                self?.showDiscovery = false
            }
            .store(in: &cancellables)

        StytchB2BClient.sessions.onMemberSessionChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    print("Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                    self?.isAuthenticated = true
                case .unavailable:
                    print("Session Unavailable\n")
                    self?.isAuthenticated = false
                }
            }.store(in: &cancellables)
    }
}

extension ContentView {
    static var publicToken: String {
        "public-token-test-b6be6a68-d178-4a2d-ac98-9579020905bf"
    }

    static let noMFAStytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.emailMagicLinks, .sso, .passwords, .oauth],
        authFlowType: .organization(slug: "no-mfa"),
        oauthProviders: [.init(provider: .google), .init(provider: .github)]
    )

    static let mfaRequiredStytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.emailMagicLinks, .sso, .passwords, .oauth],
        authFlowType: .organization(slug: "mfa-required"),
        oauthProviders: [.init(provider: .google), .init(provider: .github)]
    )

    static let discoveryStytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: publicToken,
        products: [.emailMagicLinks, .sso, .passwords, .oauth],
        authFlowType: .discovery,
        oauthProviders: [.init(provider: .google), .init(provider: .github)]
    )
}

#Preview {
    ContentView()
}
