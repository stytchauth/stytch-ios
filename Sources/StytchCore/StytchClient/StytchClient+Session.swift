import Foundation

public extension StytchClient {
    /// An opaque token representing your current session, which your servers can check with Stytch's servers to verify your session status.
    static var sessionToken: String? { Current.sessionStorage.sessionToken?.value }

    /// A session JWT (JSON Web Token), which your servers can check locally to verify your session status.
    static var sessionJwt: String? { Current.sessionStorage.sessionJwt?.value }

    /// After configuring custom storage it becomes your responsibility
    /// to maintain a reference to the CustomStorage object, to listen for updates to ``onUpdateSession``, and to pass
    /// any updated tokens back to the StytchClient via your custom storage's ``onUpdate(tokens:)`` function.
    /// NOTE: - After configuring, you should immediately call ``onUpdate(tokens:)`` to pass any previously stored
    /// values to the StytchClient. This should also be called after any subsequent updated tokens are received from your backend.
    /// - Parameter customSessionStorage: Your custom storage instance.
    static func configure(customSessionStorage: Session.CustomStorage) {
        Current.sessionStorage.customStorage = customSessionStorage
    }
}
