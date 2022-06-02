import StytchCore
import SwiftUI

let configuration: StytchDemoApp.Configuration = {
    guard let data = Bundle.main.url(forResource: "StytchConfiguration", withExtension: "plist").flatMap({ try? Data(contentsOf: $0) })
    else { fatalError("StytchConfiguration.plist should be included in the Demo App") }
    return try! PropertyListDecoder().decode(StytchDemoApp.Configuration.self, from: data)
}()

@main
struct StytchDemoApp: App {
    @State private var sessionUser: (Session, User)?
    @State private var errorAlertPresented = false
    @State private var errorMessage = ""

    var body: some Scene {
        WindowGroup {
            ContentView(serverUrl: configuration.serverUrl, sessionUser: sessionUser) {
                Task {
                    _ = try await StytchClient.sessions.revoke()
                    sessionUser = nil
                }
            } onAuth: { sessionUser = ($0, $1) }
                .padding()
                .frame(minHeight: 250)
                .task {
                    do {
                        let response = try await StytchClient.sessions.authenticate(parameters: .init(sessionDuration: 30))
                        switch response {
                        case let .authenticated(response):
                            sessionUser = (response.session, response.user)
                        case .unauthenticated:
                            break
                        }
                    } catch {
                        handle(error: error)
                    }
                }
                // Handle web-browsing deeplinks (enables universal links on macOS)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else { return }
                    handle(url: url)
                }
                // Handle deeplinks
                .onOpenURL(perform: handle(url:))
                // Prevent deeplink from opening new window
                .handlesExternalEvents(preferring: [], allowing: ["*"])
                .alert("🚨 Error 🚨", isPresented: $errorAlertPresented, actions: { EmptyView() }, message: { Text(errorMessage) })
        }
        // Prevent user from being able to create a new window
        .commands { CommandGroup(replacing: .newItem, addition: {}) }
        // Prevent deeplink from opening new window
        .handlesExternalEvents(matching: ["*"])
    }

    private func handle(url: URL) {
        Task {
            do {
                switch try await StytchClient.handle(url: url, sessionDuration: 5) {
                case let .handled(response):
                    self.sessionUser = (response.session, response.user)
                case .notHandled:
                    print("not handled")
                }
            } catch {
                handle(error: error)
            }
        }
    }

    private func handle(error: Error) {
        switch error {
        case let error as StytchError:
            errorMessage = error.message
            errorAlertPresented = true
        default:
            break
        }
    }
}

extension StytchDemoApp {
    // For simplicity, we'll mimic StytchClient.Configuration, simply to reuse that value. We'd likely have a different source of truth in a real application.
    struct Configuration: Decodable {

        let serverUrl: URL

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            do {
                serverUrl = try container.decode(URL.self, forKey: .serverUrl)
            } catch {
                let urlString = try container.decode(String.self, forKey: .serverUrl)
                guard let url = URL(string: urlString) else {
                    throw DecodingError.dataCorruptedError(forKey: .serverUrl, in: container, debugDescription: "Not a valid URL")
                }
                serverUrl = url
            }
        }

        private enum CodingKeys: String, CodingKey {
            case serverUrl = "StytchHostURL"
        }
    }
}
