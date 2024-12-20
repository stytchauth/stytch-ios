import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    let stytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
        publicToken: "your-public-token",
        products: [.emailMagicLinks, .sso, .passwords, .oauth],
        // authFlowType: .organization(slug: "org-slug"),
        authFlowType: .discovery,
        oauthProviders: [.init(provider: .google), .init(provider: .github)]
    )

    var body: some View {
        VStack(spacing: 20) {
            Button("Log In With Stytch B2B UI!") {
                viewModel.isShowingB2BUI = true
            }.font(.title).bold()

            if viewModel.isAuthenticated {
                Button("Log Out") {
                    logOut()
                }.font(.title).bold()
            }
        }
        .b2bAuthenticationSheet(configuration: stytchB2BUIConfig, isPresented: $viewModel.isShowingB2BUI, onB2BAuthCallback: {
            print("member session: \(String(describing: StytchB2BClient.sessions.memberSession))")
        })
        .padding()
        .onOpenURL { url in
            viewModel.isShowingB2BUI = true
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
    @Published var isShowingB2BUI: Bool = false
    @Published var isAuthenticated: Bool = false

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
}

#Preview {
    ContentView()
}
