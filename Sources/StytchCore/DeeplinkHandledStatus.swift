/**
 Represents whether a deeplink was able to be handled
 Session-related information when appropriate.
 */
public enum DeeplinkHandledStatus<AuthenticateResponse> {
    /// The handler was successfully able to handle the given item.
    case handled(AuthenticateResponse)
    /// The handler was unable to handle the given item.
    case notHandled
    /// The handler recognized the token type, but manual handing is required. This should only be encountered for password reset deeplinks.
    case manualHandlingRequired(DeeplinkTokenType, token: String)
}

public enum DeeplinkTokenType: String {
    case magicLinks = "magic_links"
    case multiTenantMagicLinks = "multi_tenant_magic_links"
    case oauth
    case passwordReset = "reset_password"
}
