import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var configuration: StytchUIClient.Configuration

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isAuthenticated {
                    Text("You have logged in with Stytch!")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Button("Log Out") {
                        logOut()
                    }.font(.title).bold()
                } else {
                    Button("Log In With Stytch!") {
                        viewModel.shouldPresentAuth = true
                    }.font(.title).bold()
                        .authenticationSheet(configuration: configuration, isPresented: $viewModel.shouldPresentAuth, onAuthCallback: { authenticateResponseType in
                            print("user: \(authenticateResponseType.user) - session: \(authenticateResponseType.session)")
                        })
                }
            }
            .padding()
            .onOpenURL { url in
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
    @Published var isAuthenticated: Bool = false
    @Published var shouldPresentAuth: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        StytchClient.sessions.onSessionChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionInfo in
                switch sessionInfo {
                case let .available(session, lastValidatedAtDate):
                    print("Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)\n")
                    self?.isAuthenticated = true
                    self?.shouldPresentAuth = false
                case .unavailable:
                    print("Session Unavailable\n")
                    self?.isAuthenticated = false
                    self?.shouldPresentAuth = true
                }
            }.store(in: &cancellables)
    }
}

#Preview {
    ContentView(configuration: StytchUIDemoApp.realisticStytchUIConfiguration)
}
