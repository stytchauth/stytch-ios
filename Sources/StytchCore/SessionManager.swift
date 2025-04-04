import Combine
import Foundation

enum SessionType {
    case member(MemberSession)
    case user(Session)

    var expiresAt: Date {
        switch self {
        case let .member(memberSession):
            return memberSession.expiresAt
        case let .user(session):
            return session.expiresAt
        }
    }
}

class SessionManager {
    @Dependency(\.sessionStorage) private var sessionStorage
    @Dependency(\.memberSessionStorage) private var memberSessionStorage
    @Dependency(\.userStorage) private var userStorage
    @Dependency(\.memberStorage) private var memberStorage
    @Dependency(\.organizationStorage) private var organizationStorage
    @Dependency(\.cookieClient) private var cookieClient
    @Dependency(\.keychainClient) private var keychainClient
    @Dependency(\.sessionsPollingClient) private var sessionsPollingClient
    @Dependency(\.memberSessionsPollingClient) private var memberSessionsPollingClient
    @Dependency(\.date) private var date

    var hasValidSessionToken: Bool {
        sessionToken != nil && sessionToken?.value.isEmpty == false
    }

    var hasValidSessionJwt: Bool {
        sessionJwt != nil && sessionJwt?.value.isEmpty == false
    }

    var hasValidIntermediateSessionToken: Bool {
        intermediateSessionToken != nil && intermediateSessionToken?.isEmpty == false
    }

    init() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(cookiesDidUpdate(notification:)),
                name: .NSHTTPCookieManagerCookiesChanged,
                object: nil
            )
    }

    func updateSession(
        sessionType: SessionType? = nil,
        tokens: SessionTokens? = nil,
        intermediateSessionToken: String? = nil,
        hostUrl: URL? = nil
    ) {
        self.intermediateSessionToken = intermediateSessionToken

        // If there is no session, it means that we are in MFA and all we need is the IST
        guard let sessionType else {
            resetSession()
            return
        }

        // If there is a valid sessionType then we should clear the IST because we are fully authenticated
        self.intermediateSessionToken = nil

        if let tokens = tokens {
            updatePersistentStorage(tokens: tokens)
            tokens.jwt?.updateCookie(cookieClient: cookieClient, expiresAt: sessionType.expiresAt, hostUrl: hostUrl)
            tokens.opaque.updateCookie(cookieClient: cookieClient, expiresAt: sessionType.expiresAt, hostUrl: hostUrl)
        }

        switch sessionType {
        case let .member(session):
            memberSessionStorage.update(session)
        case let .user(session):
            sessionStorage.update(session)
        }

        switch sessionType {
        case .member:
            memberSessionsPollingClient.start()
        case .user:
            sessionsPollingClient.start()
        }
    }

    func updatePersistentStorage(tokens: SessionTokens) {
        sessionToken = tokens.opaque
        sessionJwt = tokens.jwt
    }

    func resetSession() {
        sessionStorage.update(nil)
        memberSessionStorage.update(nil)
        userStorage.update(nil)
        memberStorage.update(nil)
        organizationStorage.update(nil)

        sessionToken = nil
        sessionJwt = nil

        sessionsPollingClient.stop()
        memberSessionsPollingClient.stop()
    }

    func clearEmptyTokens() {
        // Clear any successfully cached empty string on startup
        if let value = sessionToken?.value, value.isEmpty == true {
            sessionToken = nil
        }
        if let value = sessionJwt?.value, value.isEmpty == true {
            sessionJwt = nil
        }
        if let value = intermediateSessionToken, value.isEmpty == true {
            intermediateSessionToken = nil
        }
    }

    func resetSessionForUnrecoverableError(_ error: Error, forceClear: Bool = false) {
        if forceClear == true {
            resetSession()
        }

        if let stytchAPIError = error.stytchAPIError, stytchAPIError.isUnrecoverableErrorType == true {
            resetSession()
        }
    }

    @objc func cookiesDidUpdate(notification: Notification) {
        let storage = (notification.object as? HTTPCookieStorage) ?? .shared

        if let jwtCookieValue = storage.cookieValue(cookieName: SessionToken.Kind.jwt.name, date: date()) {
            sessionJwt = .jwt(jwtCookieValue)
        }

        if let opaqueCookieValue = storage.cookieValue(cookieName: SessionToken.Kind.opaque.name, date: date()) {
            sessionToken = .opaque(opaqueCookieValue)
        }
    }
}

// Session Tokens
extension SessionManager {
    private(set) var sessionToken: SessionToken? {
        get {
            try? keychainClient.getStringValue(.sessionToken).map(SessionToken.opaque)
        }
        set {
            let keychainItem: KeychainItem = .sessionToken
            if let newValue = newValue {
                try? keychainClient.setStringValue(newValue.value, for: keychainItem)
            } else {
                try? keychainClient.removeItem(item: keychainItem)
                cookieClient.deleteCookie(named: keychainItem.name)
            }
        }
    }

    private(set) var sessionJwt: SessionToken? {
        get {
            try? keychainClient.getStringValue(.sessionJwt).map(SessionToken.jwt)
        }
        set {
            let keychainItem: KeychainItem = .sessionJwt
            if let newValue = newValue {
                try? keychainClient.setStringValue(newValue.value, for: keychainItem)
            } else {
                try? keychainClient.removeItem(item: keychainItem)
                cookieClient.deleteCookie(named: keychainItem.name)
            }
        }
    }
}

// Intermediate Session Token
extension SessionManager {
    private(set) var intermediateSessionToken: String? {
        get {
            do {
                // Retrieve the IST from the keychain and check its age.
                // If it's less than 10 minutes old, return it.
                // Otherwise, remove it from the keychain and cookie storage.
                guard let result = try keychainClient.getFirstQueryResult(.intermediateSessionToken) else {
                    return nil
                }

                if isValidIntermediateSessionToken(result.createdAt), result.stringValue?.isEmpty == false {
                    return result.stringValue
                } else {
                    removeIntermediateSessionToken()
                    return nil
                }
            } catch {
                print("Error getting IST: \(error)")
                return nil
            }
        }
        set {
            do {
                if let newIST = newValue, newIST.isEmpty == false {
                    try keychainClient.setStringValue(newIST, for: .intermediateSessionToken)
                } else {
                    removeIntermediateSessionToken()
                }
            } catch {
                print("Error setting IST: \(error)")
            }
        }
    }

    private func isValidIntermediateSessionToken(_ createdAt: Date) -> Bool {
        let expirationTime: TimeInterval = 600.0 // the IST should expire after 10 minutes
        return abs(createdAt.timeIntervalSinceNow) < expirationTime
    }

    private func removeIntermediateSessionToken() {
        let keychainItem: KeychainItem = .intermediateSessionToken
        try? keychainClient.removeItem(item: keychainItem)
        cookieClient.deleteCookie(named: keychainItem.name)
    }
}

// Last Auth Method
extension SessionManager {
    var b2bLastAuthMethodUsed: StytchB2BClient.B2BAuthMethod {
        get {
            if let string = try? keychainClient.getStringValue(.b2bLastAuthMethodUsed) {
                return StytchB2BClient.B2BAuthMethod(rawValue: string) ?? .unknown
            } else {
                return StytchB2BClient.B2BAuthMethod.unknown
            }
        }
        set {
            try? keychainClient.setStringValue(newValue.rawValue, for: .b2bLastAuthMethodUsed)
        }
    }

    var consumerLastAuthMethodUsed: StytchClient.ConsumerAuthMethod {
        get {
            if let string = try? keychainClient.getStringValue(.consumerLastAuthMethodUsed) {
                return StytchClient.ConsumerAuthMethod(rawValue: string) ?? .unknown
            } else {
                return StytchClient.ConsumerAuthMethod.unknown
            }
        }
        set {
            try? keychainClient.setStringValue(newValue.rawValue, for: .consumerLastAuthMethodUsed)
        }
    }
}

extension HTTPCookieStorage {
    func cookieValue(cookieName: String, date: Date) -> String? {
        let cookie = cookies?.first { cookieName == $0.name }

        var cookieValue: String?

        // If we have an expiresDate we should attempt to use it, if not just return the cookie value
        if let expiresAt = cookie?.expiresDate {
            if expiresAt > date {
                cookieValue = cookie?.value
            }
        } else {
            cookieValue = cookie?.value
        }

        return cookieValue
    }
}
