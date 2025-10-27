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
    @Dependency(\.userDefaultsClient) private var userDefaultsClient
    @Dependency(\.sessionsPollingClient) private var sessionsPollingClient
    @Dependency(\.memberSessionsPollingClient) private var memberSessionsPollingClient
    @Dependency(\.date) private var date
    @Dependency(\.keychainClient) private var keychainClient

    var hasValidSessionToken: Bool {
        sessionToken != nil && sessionToken?.value.isEmpty == false
    }

    var hasValidSessionJwt: Bool {
        sessionJwt != nil && sessionJwt?.value.isEmpty == false
    }

    var hasValidIntermediateSessionToken: Bool {
        intermediateSessionToken != nil && intermediateSessionToken?.isEmpty == false
    }

    func updateSession(
        sessionType: SessionType? = nil,
        tokens: SessionTokens? = nil,
        intermediateSessionToken: String? = nil
    ) {
        self.intermediateSessionToken = intermediateSessionToken

        // If there is no session, it means that we are in MFA and all we need is the IST
        guard let sessionType = sessionType else {
            resetSession()
            return
        }

        // If there is a valid sessionType then we should clear the IST because we are fully authenticated
        self.intermediateSessionToken = nil

        if let tokens = tokens {
            updatePersistentStorage(tokens: tokens)
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
            try? userDefaultsClient.getStringValue(.sessionToken).map(SessionToken.opaque)
        }
        set {
            let userDefaultsItem: EncryptedUserDefaultsItem = .sessionToken
            if let newValue = newValue {
                try? userDefaultsClient.setStringValue(newValue.value, for: userDefaultsItem)
            } else {
                try? userDefaultsClient.removeItem(item: userDefaultsItem)
            }
        }
    }

    private(set) var sessionJwt: SessionToken? {
        get {
            try? userDefaultsClient.getStringValue(.sessionJwt).map(SessionToken.jwt)
        }
        set {
            let userDefaultsItem: EncryptedUserDefaultsItem = .sessionJwt
            if let newValue = newValue {
                try? userDefaultsClient.setStringValue(newValue.value, for: userDefaultsItem)
            } else {
                try? userDefaultsClient.removeItem(item: userDefaultsItem)
            }
        }
    }

    var sessionId: Session.ID? {
        try? userDefaultsClient.getObject(Session.self, for: .session)?.sessionId
    }

    var memberSessionId: MemberSession.ID? {
        try? userDefaultsClient.getObject(MemberSession.self, for: .memberSession)?.memberSessionId
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
                guard let result = try userDefaultsClient.getItem(item: .intermediateSessionToken) else {
                    return nil
                }
                guard let istLastValidatedAtDate = try userDefaultsClient.getObject(Date.self, for: .lastValidatedAtDate(EncryptedUserDefaultsItem.intermediateSessionToken.name)) else {
                    return nil
                }
                if isValidIntermediateSessionToken(istLastValidatedAtDate), result.stringValue?.isEmpty == false {
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
                    try userDefaultsClient.setStringValue(newIST, for: .intermediateSessionToken)
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
        let userDefaultsItem: EncryptedUserDefaultsItem = .intermediateSessionToken
        try? userDefaultsClient.removeItem(item: userDefaultsItem)
    }
}

// Last Auth Method
extension SessionManager {
    var b2bLastAuthMethodUsed: StytchB2BClient.B2BAuthMethod {
        get {
            if let string = try? userDefaultsClient.getStringValue(.b2bLastAuthMethodUsed) {
                return StytchB2BClient.B2BAuthMethod(rawValue: string) ?? .unknown
            } else {
                return StytchB2BClient.B2BAuthMethod.unknown
            }
        }
        set {
            try? userDefaultsClient.setStringValue(newValue.rawValue, for: .b2bLastAuthMethodUsed)
        }
    }

    var consumerLastAuthMethodUsed: StytchClient.ConsumerAuthMethod {
        get {
            if let string = try? userDefaultsClient.getStringValue(.consumerLastAuthMethodUsed) {
                return StytchClient.ConsumerAuthMethod(rawValue: string) ?? .unknown
            } else {
                return StytchClient.ConsumerAuthMethod.unknown
            }
        }
        set {
            try? userDefaultsClient.setStringValue(newValue.rawValue, for: .consumerLastAuthMethodUsed)
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

extension SessionManager {
    func processPotentialBiometricRegistrationCleanups(currentUser: User, lastAuthenticatedUserId: String?) {
        #if !os(tvOS) && !os(watchOS)
        guard let previousUserId = lastAuthenticatedUserId else {
            // if we have no previous user, just clean up any local registrations that don't exist on the server
            return StytchClient.biometrics.cleanupPotentiallyOrphanedBiometricRegistrations()
        }
        if previousUserId == currentUser.userId.rawValue {
            // if the previous and current user are the same, only clean up any local registrations that don't exist on the server
            StytchClient.biometrics.cleanupPotentiallyOrphanedBiometricRegistrations()
        } else {
            // if there is an existing biometric registration on the device, delete the local registration to enable the new user to
            // create their own biometric registration
            let existingBiometricRegistrationId = try? userDefaultsClient.getStringValue(.biometricKeyRegistration)
            if existingBiometricRegistrationId != nil {
                try? keychainClient.removeItem(item: .privateKeyRegistration)
                try? keychainClient.removeItem(item: .biometricKeyRegistration)
            }
        }
        #endif
    }
}
