import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter Public Token", text: $viewModel.publicToken, onCommit: viewModel.saveToUserDefaults)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Enter Org Slug (optional)", text: $viewModel.orgSlug, onCommit: viewModel.saveToUserDefaults)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Launch Discovery Flow") {
                viewModel.saveToUserDefaults()
                viewModel.launchDiscoveryFlow()
            }
            .font(.title).bold()

            Button("Launch Org Specific Flow") {
                viewModel.saveToUserDefaults()
                viewModel.launchOrgSpecificFlow()
            }
            .font(.title).bold()

            if viewModel.isAuthenticated {
                Button("Log Out") {
                    viewModel.logOut()
                }
                .font(.title).bold()
            }
        }
        .b2bAuthenticationSheet(configuration: viewModel.stytchB2BUIConfig, isPresented: $viewModel.isShowingB2BUI, onB2BAuthCallback: {
            print("member session: \(String(describing: StytchB2BClient.sessions.memberSession))")
        })
        .padding()
        .onAppear {
            viewModel.loadFromUserDefaults()
        }
        .onOpenURL { url in
            viewModel.handleOpenURL(url)
        }
    }
}

class ContentViewModel: ObservableObject {
    // To hard-code the publicToken or orgSlug instead of inputting it through the UI, set it here.
    @Published var publicToken: String = ""
    @Published var orgSlug: String = ""

    @Published var isShowingB2BUI: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var stytchB2BUIConfig: StytchB2BUIClient.Configuration = .empty

    private var cancellables = Set<AnyCancellable>()

    init() {
        StytchB2BUIClient.dismissUI
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isShowingB2BUI = false
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

    func loadFromUserDefaults() {
        if publicToken.isEmpty == true {
            publicToken = UserDefaults.standard.string(forKey: "publicToken") ?? ""
        }

        if orgSlug.isEmpty == true {
            orgSlug = UserDefaults.standard.string(forKey: "orgSlug") ?? ""
        }
    }

    func saveToUserDefaults() {
        UserDefaults.standard.set(publicToken, forKey: "publicToken")
        UserDefaults.standard.set(orgSlug, forKey: "orgSlug")
    }

    func launchDiscoveryFlow() {
        stytchB2BUIConfig = createConfiguration(authFlowType: .discovery)
        isShowingB2BUI = true
    }

    func launchOrgSpecificFlow() {
        guard !orgSlug.isEmpty else {
            print("Org Slug is required for this flow")
            return
        }
        stytchB2BUIConfig = createConfiguration(authFlowType: .organization(slug: orgSlug))
        isShowingB2BUI = true
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

    func handleOpenURL(_ url: URL) {
        isShowingB2BUI = true
        let didHandle = StytchB2BUIClient.handle(url: url)
        print("StytchUIClient didHandle: \(didHandle) - url: \(url)")
    }

    private func createConfiguration(authFlowType: StytchB2BUIClient.AuthFlowType) -> StytchB2BUIClient.Configuration {
        .init(
            publicToken: publicToken,
            products: [.emailMagicLinks, .emailOtp, .sso, .passwords, .oauth],
            authFlowType: authFlowType,
            oauthProviders: [.init(provider: .google), .init(provider: .github)]
        )
    }
}

#Preview {
    ContentView()
}
