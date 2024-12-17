import Combine
import Foundation

final class SessionManager {
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

    var persistedSessionIdentifiersExist: Bool {
        (sessionJwt ?? sessionToken) != nil
    }

    private(set) var sessionToken: SessionToken? {
        get {
            try? keychainClient.get(.sessionToken).map(SessionToken.opaque)
        }
        set {
            let keychainItem: KeychainClient.Item = .sessionToken
            if let newValue = newValue {
                try? keychainClient.set(newValue.value, for: keychainItem)
            } else {
                try? keychainClient.removeItem(keychainItem)
                cookieClient.deleteCookie(named: keychainItem.name)
            }
        }
    }

    private(set) var sessionJwt: SessionToken? {
        get {
            try? keychainClient.get(.sessionJwt).map(SessionToken.jwt)
        }
        set {
            let keychainItem: KeychainClient.Item = .sessionJwt
            if let newValue = newValue {
                try? keychainClient.set(newValue.value, for: keychainItem)
            } else {
                try? keychainClient.removeItem(keychainItem)
                cookieClient.deleteCookie(named: keychainItem.name)
            }
        }
    }

    private(set) var intermediateSessionToken: String? {
        get {
            let tenMinutes = 600.0
            let keychainItem: KeychainClient.Item = .intermediateSessionToken

            // If we have a valid IST stored in the keychain
            // Check to see if it is less than 10 minutes old
            // If it is less than 10 minutes, then return it
            // If it is more than 10 minutes old then remove it from the keychain and cookie storage
            if let intermediateSessionTokenQueryResult = try? keychainClient.getQueryResult(keychainItem) {
                if abs(intermediateSessionTokenQueryResult.createdAt.timeIntervalSinceNow) < tenMinutes {
                    return intermediateSessionTokenQueryResult.stringValue
                } else {
                    try? keychainClient.removeItem(keychainItem)
                    cookieClient.deleteCookie(named: keychainItem.name)
                    return nil
                }
            } else {
                return nil
            }
        }
        set {
            let keychainItem: KeychainClient.Item = .intermediateSessionToken
            if let newValue = newValue {
                try? keychainClient.set(newValue, for: keychainItem)
            } else {
                try? keychainClient.removeItem(keychainItem)
                cookieClient.deleteCookie(named: keychainItem.name)
            }
        }
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

    internal func updateSession(
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

        switch sessionType {
        case let .member(session):
            memberSessionStorage.update(session)
        case let .user(session):
            sessionStorage.update(session)
        }

        if let tokens = tokens {
            updatePersistentStorage(tokens: tokens)
            tokens.jwt.updateCookie(cookieClient: cookieClient, expiresAt: sessionType.expiresAt, hostUrl: hostUrl)
            tokens.opaque.updateCookie(cookieClient: cookieClient, expiresAt: sessionType.expiresAt, hostUrl: hostUrl)
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
