#if !os(tvOS) && !os(watchOS)
import Foundation
import LocalAuthentication

// swiftlint:disable type_contents_order prefer_self_in_static_references

public enum LocalAuthenticationContextManager {
    /// The shared instance of `LAContext` used by default.
    public static var laContext = LAContext()

    /// The current local authentication context, exposed as `LAContextEvaluating` for easier unit testing.
    /// Defaults to the shared `laContext` unless explicitly overridden.
    public static var localAuthenticationContext: LAContextEvaluating = laContext

    /// Replaces the current `localAuthenticationContext` with a custom context.
    /// Primarily intended for use in unit tests.
    public static func setLocalAuthenticationContext(context: LAContextEvaluating) {
        localAuthenticationContext = context
    }

    /// Updates the localized strings on the shared `laContext` instance.
    /// Note that this does not update the `localAuthenticationContext` if it has been overridden.
    public static func updateLaContextStrings(strings: LAContextPromptStrings) {
        laContext.localizedReason = strings.localizedReason
        laContext.localizedFallbackTitle = strings.localizedFallbackTitle
        laContext.localizedCancelTitle = strings.localizedCancelTitle
    }
}

/// A type that encapsulates localized prompt strings for an `LAContext`.
public struct LAContextPromptStrings: Codable, Sendable {
    public let localizedReason: String
    public let localizedFallbackTitle: String?
    public let localizedCancelTitle: String?

    public init(
        localizedReason: String,
        localizedFallbackTitle: String? = nil,
        localizedCancelTitle: String? = nil
    ) {
        self.localizedReason = localizedReason
        self.localizedFallbackTitle = localizedFallbackTitle
        self.localizedCancelTitle = localizedCancelTitle
    }

    public static var defaultPromptStrings: LAContextPromptStrings {
        let localizedReason = NSLocalizedString(
            "keychain_client.la_context_reason",
            value: "Authenticate with biometrics",
            comment: "The user-presented reason for biometric authentication prompts"
        )
        return LAContextPromptStrings(localizedReason: localizedReason)
    }
}
#endif
