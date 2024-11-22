import Combine
import StytchCore
import SwiftUI
import UIKit

public enum StytchB2BUIClient {
    // The UI configuration to determine which kinds of auth are needed, defaults to empty, must be overridden in configure
    static var configuration: Configuration = .empty

    private static var cancellable: AnyCancellable?

    /// Configures the `StytchB2BUIClient`, setting the `publicToken`, `config` and `hostUrl` for StytchB2BClient.
    /// - Parameters:
    ///   - configuration: The UI configuration to determine which kinds of auth are needed, defaults to empty
    public static func configure(configuration: Configuration) {
        StytchB2BClient.configure(publicToken: configuration.publicToken, hostUrl: configuration.hostUrl)
        FontLoader.loadFonts()
        Self.configuration = configuration
    }

    /// Use this function to handle incoming deeplinks for password resets.
    /// If presenting from SwiftUI, ensure the sheet is presented before calling this handler.
    /// You can use `StytchB2BClient.canHandle(url:)` to determine if you should present the SwiftUI sheet before calling this handler.
    public static func handle(url: URL, from controller: UIViewController? = nil) -> Bool {
        print(controller as Any)
        Task { @MainActor in
            switch try await StytchB2BClient.handle(url: url, sessionDuration: configuration.sessionDurationMinutes) {
            case let .handled(responseData):
                switch responseData {
                case let .auth(response):
                    print(response)
                case let .mfauth(response):
                    print(response)
                case let .mfaOAuth(response):
                    print(response)
                case let .discovery(response):
                    print(response)
                case let .discoveryOauth(response):
                    print(response)
                }
            case .notHandled:
                break
            case let .manualHandlingRequired(tokenType, token):
                print(tokenType)
                print(token)
            }
        }
        return StytchB2BClient.canHandle(url: url)
    }

    static func setUpSessionChangeListener() {
        cancellable = StytchB2BClient.sessions.onMemberSessionChange
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                Self.cancellable = nil
            }
    }
}
