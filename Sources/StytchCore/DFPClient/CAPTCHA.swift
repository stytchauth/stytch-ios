#if os(iOS)
import Foundation
import RecaptchaEnterprise

internal protocol RecaptchaProvider {
    mutating func configure(siteKey: String) async -> Void

    func getCaptchaToken() async -> String

    func isConfigured() -> Bool
}

private struct RecaptchaProviderImplementation: RecaptchaProvider {
    private var recaptchaClient: RecaptchaClient?

    mutating func configure(siteKey: String) async -> Void {
        do {
            recaptchaClient = try await Recaptcha.getClient(withSiteKey: siteKey)
        } catch let error as RecaptchaError {
            print("RecaptchaClient creation error: \(String(describing: error.errorMessage)).")
        } catch let error {
            print("RecaptchaClient creation error: \(String(describing: error))")
        }
    }

    func getCaptchaToken() async -> String {
        guard let recaptchaClient = recaptchaClient else {
            return ""
        }
        do {
            return try await recaptchaClient.execute(withAction: RecaptchaAction.login)
        } catch let error as RecaptchaError {
            print("RecaptchaClient execute error: \(String(describing: error.errorMessage)).")
            return ""
        } catch let error {
            print("RecaptchaClient execute error: \(String(describing: error)).")
            return ""
        }
    }

    func isConfigured() -> Bool {
        recaptchaClient != nil
    }
}

final class CAPTCHA {
    private var recaptchaProvider: RecaptchaProvider

    init(recaptchaProvider: RecaptchaProvider = RecaptchaProviderImplementation()) {
        self.recaptchaProvider = recaptchaProvider
    }

    func isConfigured() -> Bool {
        recaptchaProvider.isConfigured()
    }

    func executeRecaptcha() async -> String {
        await recaptchaProvider.getCaptchaToken()
    }

    func setCaptchaClient(siteKey: String) async {
        await recaptchaProvider.configure(siteKey: siteKey)
    }
}
#endif
