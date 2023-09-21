#if os(iOS)
import Foundation
import RecaptchaEnterprise

internal protocol CaptchaProvider {
    func setCaptchaClient(siteKey: String) async

    func executeRecaptcha() async -> String

    func isConfigured() -> Bool
}

final class CaptchaClient : CaptchaProvider {
    private var recaptchaClient: RecaptchaClient?

    func isConfigured() -> Bool {
        recaptchaClient != nil
    }

    func executeRecaptcha() async -> String {
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

    func setCaptchaClient(siteKey: String) async {
        do {
            recaptchaClient = try await Recaptcha.getClient(withSiteKey: siteKey)
        } catch let error as RecaptchaError {
            print("RecaptchaClient creation error: \(String(describing: error.errorMessage)).")
        } catch {
            print("RecaptchaClient creation error: \(String(describing: error))")
        }
    }
}
#endif
