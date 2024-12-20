import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    let configuration: StytchUIClient.Configuration = .init(
        publicToken: "your-public-token",
        products: [.passwords, .emailMagicLinks, .otp, .oauth],
        oauthProviders: [.apple, .thirdParty(.google)],
        otpOptions: .init(methods: [.sms])
    )

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Log In With Stytch!") {
                    viewModel.shouldShowB2CUI = true
                }.font(.title).bold()

                if viewModel.shouldShowB2CUI == false {
                    Text("You have logged in with Stytch!")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Button("Log Out") {
                        logOut()
                    }.font(.title).bold()
                }
            }
            .authenticationSheet(configuration: configuration, isPresented: $viewModel.shouldShowB2CUI, onAuthCallback: { authenticateResponseType in
                print("user: \(authenticateResponseType.user) - session: \(authenticateResponseType.session)")
            })
            .padding()
            .onOpenURL { url in
                viewModel.shouldShowB2CUI = true
                let didHandle = StytchUIClient.handle(url: url)
                print("StytchUIClient didHandle: \(didHandle) - url: \(url)")
            }
        }
    }

    func logOut() {
        Task {
            do {
                let response = try await StytchClient.sessions.revoke(parameters: .init(forceClear: true))
                print("log out response: \(response)")
            } catch {
                print("log out error: \(error.errorInfo)")
            }
        }
    }
}

class ContentViewModel: ObservableObject {
    @Published var shouldShowB2CUI: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    print("Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                    self?.shouldShowB2CUI = false
                case .unavailable:
                    print("Session Unavailable\n")
                    self?.shouldShowB2CUI = true
                }
            }.store(in: &cancellables)
    }
}

#Preview {
    ContentView()
}
