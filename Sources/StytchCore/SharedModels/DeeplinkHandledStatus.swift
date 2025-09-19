/**
 Represents whether a deeplink was able to be handled
 Session-related information when appropriate.
 */
public enum DeeplinkHandledStatus<AuthenticateResponse: Sendable, DeeplinkTokenType: Sendable, DeeplinkRedirectType: Sendable>: Sendable {
    /// The handler was successfully able to handle the given item.
    case handled(response: AuthenticateResponse)
    /// The handler was unable to handle the given item.
    case notHandled
    /// The handler recognized the token type, but manual handing is required. This should only be encountered for password reset deeplinks.
    case manualHandlingRequired(DeeplinkTokenType, DeeplinkRedirectType, token: String)
}
