import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isAuthenticated == true {
                    Text("You have logged in with Stytch!")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text(viewModel.sessionExpirationText)
                        .font(.headline)
                        .foregroundColor(.gray)

                    Button("Log Out") {
                        logOut()
                    }.font(.title).bold()
                } else {
                    Button("Log In With Stytch!") {
                        viewModel.shouldShowB2CUI = true
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
    @Published var isAuthenticated: Bool = false
    @Published var sessionExpirationText: String = ""
    private var expirationTimer: Timer?

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
        StytchUIClient.dismissUI
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.shouldShowB2CUI = false
            }
            .store(in: &cancellables)

        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    print("Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                    print("StytchClient.sessions.sessionToken: \(StytchClient.sessions.sessionToken?.value ?? "no sessionToken")")
                    print("StytchClient.sessions.sessionJwt: \(StytchClient.sessions.sessionJwt?.value ?? "no sessionJwt")")
                    self?.isAuthenticated = true
                    self?.updateExpirationCountdown(to: session.expiresAt)
                case .unavailable:
                    print("Session Unavailable\n")
                    self?.isAuthenticated = false
                    self?.sessionExpirationText = ""
                    self?.expirationTimer?.invalidate()
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
        stytchClientConfiguration: .init(publicToken: "public-token-test-728f8b82-2a20-4926-b077-a8ca7d67e1b2"),
        products: [.passwords, .emailMagicLinks, .otp, .biometrics, .oauth],
        navigation: Navigation(closeButtonStyle: .close(.right)),
        oauthProviders: [.apple, .thirdParty(.google)],
        otpOptions: .init(methods: [.sms, .whatsapp])
    )

    private func updateExpirationCountdown(to expirationDate: Date) {
        expirationTimer?.invalidate()

        func updateLabel() {
            let remaining = expirationDate.timeIntervalSinceNow
            if remaining <= 0 {
                sessionExpirationText = "Session expired"
                expirationTimer?.invalidate()
            } else {
                let minutes = Int(remaining) / 60
                let seconds = Int(remaining) % 60
                sessionExpirationText = "Your session expires in \(minutes) min \(seconds) sec"
            }
        }

        expirationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateLabel()
        }
        RunLoop.main.add(expirationTimer!, forMode: .common)
        updateLabel()
    }
}

#Preview {
    ContentView()
}
