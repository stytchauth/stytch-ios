import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

// swiftlint:disable identifier_name
#if DEBUG
var Current: Environment = .init()
#else
let Current: Environment = .init()
#endif
// swiftlint:enable identifier_name

struct Environment {
    var clientInfo: ClientInfo = .init()

    var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            do {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    return date
                }
                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: dateString) {
                    return date
                }
                throw DecodingError.dataCorrupted(
                    .init(codingPath: decoder.codingPath, debugDescription: "Expected date string to be ISO8601-formatted.")
                )
            }
        }
        return decoder
    }()

    var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    var defaults: UserDefaults = .standard

    var appleOAuthClient: AppleOAuthClient = .live

    var networkingClient: NetworkingClient = .live

    var cryptoClient: CryptoClient = .live

    var sessionsPollingClient: PollingClient = .sessions

    var memberSessionsPollingClient: PollingClient = .memberSessions

    let sessionStorage: SessionStorage = .init()

    var localStorage: LocalStorage = .init()

    var cookieClient: CookieClient = .live

    var keychainClient: KeychainClient = .live

    #if !os(watchOS)
    private var _webAuthSessionClient: Any? = {
        if #available(tvOS 16.0, *) {
            return WebAuthenticationSessionClient.live
        }
        return nil
    }()

    @available(tvOS 16.0, *)
    var webAuthSessionClient: WebAuthenticationSessionClient {
        // swiftlint:disable:next force_cast
        get { _webAuthSessionClient as! WebAuthenticationSessionClient }
        set { _webAuthSessionClient = newValue }
    }

    private var _passkeysClent: Any? = {
        if #available(macOS 12.0, iOS 16.0, tvOS 16.0, *) {
            return PasskeysClient.live
        }
        return nil
    }()

    @available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
    var passkeysClient: PasskeysClient {
        // swiftlint:disable:next force_cast
        get { _passkeysClent as! PasskeysClient }
        set { _passkeysClent = newValue }
    }
    #endif
    #if os(iOS)
    var dfpClient: DFPClient = .live
    var captcha: CAPTCHA = .live
    #endif
    var date: () -> Date = Date.init

    var uuid: () -> UUID = UUID.init

    var asyncAfter: (DispatchQueue, DispatchTime, @escaping () -> Void) -> Void = { $0.asyncAfter(deadline: $1, execute: $2) }

    var timer: (TimeInterval, RunLoop, @escaping () -> Void) -> Timer = { interval, runloop, task in
        let timer = Timer(timeInterval: interval, repeats: true) { _ in task() }
        runloop.add(timer, forMode: .common)
        return timer
    }

    #if !os(watchOS)
    var openUrl: (URL) -> Void = { url in
        DispatchQueue.main.async {
            #if os(macOS)
            NSWorkspace.shared.open(url)
            #else
            UIApplication.shared.open(url)
            #endif
        }
    }
    #endif
}
