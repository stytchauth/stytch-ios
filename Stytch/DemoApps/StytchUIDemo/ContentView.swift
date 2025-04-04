import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

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
            .authenticationSheet(configuration: viewModel.configuration, isPresented: $viewModel.shouldShowB2CUI)
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
    var date = Date()

    init() {
        startObservables()

        // Used to measure time until StytchClient.isInitialized fires
        date = Date()

        // To start the underlying client’s observables before displaying the UI, call configure separately.
        StytchUIClient.configure(configuration: configuration)
    }

    func startObservables() {
        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    print("Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                    print("StytchClient.sessions.sessionToken: \(StytchClient.sessions.sessionToken?.value ?? "no sessionToken")")
                    print("StytchClient.sessions.sessionJwt: \(StytchClient.sessions.sessionJwt?.value ?? "no sessionJwt")")
                    self?.shouldShowB2CUI = false
                case .unavailable:
                    print("Session Unavailable\n")
                    self?.shouldShowB2CUI = true
                }
            }.store(in: &cancellables)

        StytchClient.user.onUserChange
            .receive(on: DispatchQueue.main)
            .sink { userInfo in
                switch userInfo {
                case let .available(user, lastValidatedAtDate):
                    print("User Available: \(user.name) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                case .unavailable:
                    print("User Unavailable\n")
                }
            }.store(in: &cancellables)

        StytchClient.isInitialized
            .receive(on: DispatchQueue.main)
            .sink { isInitialized in
                print(String(format: "StytchClient.isInitialized took %.2f seconds to fire.", Date().timeIntervalSince(self.date)))
                print("isInitialized: \(isInitialized)")
            }.store(in: &cancellables)

        StytchUIClient.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { error in
                print("Error from StytchUIClient:")
                print(error.errorInfo)
            }
            .store(in: &cancellables)
    }

    let configuration: StytchUIClient.Configuration = .init(
        stytchClientConfiguration: .init(publicToken: "public-token-test-..."),
        products: [.passwords, .emailMagicLinks, .otp, .oauth],
        navigation: Navigation(closeButtonStyle: .close(.right)),
        oauthProviders: [.apple, .thirdParty(.google)],
        otpOptions: .init(methods: [.sms, .whatsapp])
    )
}

#Preview {
    ContentView()
}
