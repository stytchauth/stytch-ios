import Foundation
import RecaptchaEnterprise

struct CAPTCHA {
    var getRecaptchaClient: (String) async throws -> RecaptchaClient?

    var executeRecaptcha: (RecaptchaClient?) async throws -> String?

    init(
        getRecaptchaClient: @escaping (String) async throws -> RecaptchaClient?,
        executeRecaptcha: @escaping (RecaptchaClient?) async throws -> String?
    ) {
        self.getRecaptchaClient = getRecaptchaClient
        self.executeRecaptcha = executeRecaptcha
    }
}
