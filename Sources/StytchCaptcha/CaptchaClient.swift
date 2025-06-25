import Foundation
import StytchCore

#if canImport(RecaptchaEnterprise)
import RecaptchaEnterprise

/// Implementation of CaptchaProvider that uses Google's RecaptchaEnterprise
public final class CaptchaClient: CaptchaProvider {
    private var recaptchaClient: RecaptchaClient?
    
    public init() {}

    public func isConfigured() -> Bool {
        recaptchaClient != nil
    }

    public func executeRecaptcha() async -> String {
        guard let recaptchaClient = recaptchaClient else {
            return ""
        }
        do {
            return try await recaptchaClient.execute(withAction: RecaptchaAction.login)
        } catch let error as RecaptchaError {
            print("RecaptchaClient execute error: \(String(describing: error.errorMessage)).")
            return ""
        } catch {
            print("RecaptchaClient execute error: \(String(describing: error)).")
            return ""
        }
    }

    public func setCaptchaClient(siteKey: String) async {
        do {
            recaptchaClient = try await Recaptcha.fetchClient(withSiteKey: siteKey)
        } catch let error as RecaptchaError {
            print("RecaptchaClient creation error: \(String(describing: error.errorMessage)).")
        } catch {
            print("RecaptchaClient creation error: \(String(describing: error))")
        }
    }
}
#else
/// Fallback implementation when RecaptchaEnterprise is not available
public final class CaptchaClient: CaptchaProvider {
    public init() {}
    
    public func setCaptchaClient(siteKey: String) async {
        print("RecaptchaEnterprise not available on this platform")
    }
    
    public func executeRecaptcha() async -> String {
        return ""
    }
    
    public func isConfigured() -> Bool {
        return false
    }
}
#endif 