#if os(iOS)
import Foundation
import RecaptchaEnterprise

extension CAPTCHA {
    static let live: Self = .init(
        getRecaptchaClient: { siteKey in
            try await Task {
                do {
                    return try await Recaptcha.getClient(withSiteKey: siteKey)
                } catch let error as RecaptchaError {
                    print("RecaptchaClient creation error: \(String(describing: error.errorMessage)).")
                    return nil
                }
            }.value
        },
        executeRecaptcha: { recaptchaClient in
            try await Task {
                do {
                    return try await recaptchaClient?.execute(withAction: RecaptchaAction.login)
                } catch let error as RecaptchaError {
                    print("RecaptchaClient execute error: \(String(describing: error.errorMessage)).")
                    return nil
                }
            }.value
        }
    )
}
#endif
