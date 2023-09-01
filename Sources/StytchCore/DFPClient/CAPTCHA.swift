#if os(iOS)
import Foundation
import RecaptchaEnterprise

final class CAPTCHA {
    var recaptchaClient: RecaptchaClient? = nil

    func executeRecaptcha() async throws -> String? {
        do {
            return try await recaptchaClient?.execute(withAction: RecaptchaAction.login)
        } catch let error as RecaptchaError {
            print("RecaptchaClient execute error: \(String(describing: error.errorMessage)).")
            return nil
        }
    }
    
    func setCaptchaClient(siteKey: String) async throws {
        do {
            recaptchaClient = try await Recaptcha.getClient(withSiteKey: siteKey)
        } catch let error as RecaptchaError {
            print("RecaptchaClient creation error: \(String(describing: error.errorMessage)).")
        }
    }
}
#endif
