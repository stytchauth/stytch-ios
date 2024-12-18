import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Button("Show No MFA") {
                viewModel.showNoMFA = true
                viewModel.saveState()
            }.font(.title).bold()
                .b2bAuthenticationSheet(configuration: Self.noMFAStytchB2BUIConfig, isPresented: $viewModel.showNoMFA, onB2BAuthCallback: {
                    print("member session: \(String(describing: StytchB2BClient.sessions.memberSession))")
                })

            Button("Show MFA") {
                viewModel.showMFA = true
                viewModel.saveState()
            }.font(.title).bold()
                .b2bAuthenticationSheet(configuration: Self.mfaRequiredStytchB2BUIConfig, isPresented: $viewModel.showMFA, onB2BAuthCallback: {
                    print("member session: \(String(describing: StytchB2BClient.sessions.memberSession))")
                })

            Button("Show Discovery") {
                viewModel.showDiscovery = true
                viewModel.saveState()
            }.font(.title).bold()
                .b2bAuthenticationSheet(configuration: Self.discoveryStytchB2BUIConfig, isPresented: $viewModel.showDiscovery, onB2BAuthCallback: {
                    print("member session: \(String(describing: StytchB2BClient.sessions.memberSession))")
                })

            if viewModel.isAuthenticated {
                Button("Log Out") {
                    logOut()
                }.font(.title).bold()
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
        restoreState()

        StytchB2BUIClient.dismissUI
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.showNoMFA = false
                self?.showMFA = false
                self?.showDiscovery = false
                self?.saveState()
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

    // saveState() and restoreState() help us keep track of what flow we were in between launches
    // This will help us handle a deeplink if the app was in a cold state
    func saveState() {
        UserDefaults.standard.setValue(showNoMFA, forKey: UserDefaultsKeys.showNoMFA.rawValue)
        UserDefaults.standard.setValue(showMFA, forKey: UserDefaultsKeys.showMFA.rawValue)
        UserDefaults.standard.setValue(showDiscovery, forKey: UserDefaultsKeys.showDiscovery.rawValue)
    }

    func restoreState() {
        showNoMFA = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showNoMFA.rawValue)
        showMFA = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showMFA.rawValue)
        showDiscovery = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showDiscovery.rawValue)
    }

    enum UserDefaultsKeys: String {
        case showNoMFA
        case showMFA
        case showDiscovery
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
