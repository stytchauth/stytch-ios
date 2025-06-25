import Foundation

/// Protocol defining the interface for captcha providers
public protocol CaptchaProvider: Sendable {
    func setCaptchaClient(siteKey: String) async
    func executeRecaptcha() async -> String
    func isConfigured() -> Bool
}

/// No-op implementation of CaptchaProvider for when captcha functionality is not needed
public final class NoOpCaptchaProvider: CaptchaProvider {
    public init() {}
    
    public func setCaptchaClient(siteKey: String) async {
        // No-op implementation
    }
    
    public func executeRecaptcha() async -> String {
        // Returns empty string when no captcha is configured
        return ""
    }
    
    public func isConfigured() -> Bool {
        // Always returns false for no-op implementation
        return false
    }
}


