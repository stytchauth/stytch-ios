import StytchCore
import Foundation

enum CalledMethod {
    case magicLinksLoginOrCreate
    case magicLinksSend

    case passwordsCreate
    case passwordsAuthenticate
    case passwordsResetByEmailStart
    case passwordsResetByEmail
    case passwordsStrengthCheck
    case passwordsResetBySession

    case otpLoginOrCreate
    case otpSend
    case otpAuthenticate

    case oauthAppleStart
    case oauthThirdPartyStart
    case oauthAuthenticate
}

class PasswordsSpy: PasswordsProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func create(parameters: StytchClient.Passwords.PasswordParameters) async throws -> StytchClient.Passwords.CreateResponse {
        callback(.passwordsCreate)
        return StytchClient.Passwords.CreateResponse.mock
    }

    func authenticate(parameters: StytchClient.Passwords.PasswordParameters) async throws -> AuthenticateResponse {
        callback(.passwordsAuthenticate)
        return AuthenticateResponse.mock
    }

    func resetByEmailStart(parameters: StytchClient.Passwords.ResetByEmailStartParameters) async throws -> BasicResponse {
        callback(.passwordsResetByEmailStart)
        return BasicResponse.mock
    }

    func resetByEmail(parameters: StytchClient.Passwords.ResetByEmailParameters) async throws -> AuthenticateResponse {
        callback(.passwordsResetByEmail)
        return AuthenticateResponse.mock
    }

    func strengthCheck(parameters: StytchClient.Passwords.StrengthCheckParameters) async throws -> StytchClient.Passwords.StrengthCheckResponse {
        callback(.passwordsStrengthCheck)
        return StytchClient.Passwords.StrengthCheckResponse.successMock
    }

    func resetBySession(parameters: StytchClient.Passwords.ResetBySessionParameters) async throws -> AuthenticateResponse {
        callback(.passwordsResetBySession)
        return AuthenticateResponse.mock
    }
}

class MagicLinksSpy: MagicLinksEmailProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func loginOrCreate(parameters: StytchClient.MagicLinks.Email.Parameters) async throws -> BasicResponse {
        callback(.magicLinksLoginOrCreate)
        return BasicResponse.mock
    }

    func send(parameters: StytchClient.MagicLinks.Email.Parameters) async throws -> BasicResponse {
        callback(.magicLinksSend)
        return BasicResponse.mock
    }
}

class OTPSpy: OTPProtocol {
    func loginOrCreate(parameters: StytchClient.OTP.Parameters) async throws -> StytchClient.OTP.OTPResponse {
        callback(.otpLoginOrCreate)
        return StytchClient.OTP.OTPResponse.mock
    }

    func send(parameters: StytchClient.OTP.Parameters) async throws -> StytchClient.OTP.OTPResponse {
        callback(.otpSend)
        return StytchClient.OTP.OTPResponse.mock
    }

    func authenticate(parameters: StytchClient.OTP.AuthenticateParameters) async throws -> AuthenticateResponse {
        callback(.otpAuthenticate)
        return AuthenticateResponse.mock
    }

    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }
}

class AppleSpy: AppleOAuthProviderProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func start(parameters: StytchClient.OAuth.Apple.StartParameters) async throws -> StytchClient.OAuth.Apple.AuthenticateResponse {
        callback(.oauthAppleStart)
        return .mock
    }
}

class OAuthSpy: OAuthProviderProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func authenticate(parameters: StytchClient.OAuth.AuthenticateParameters) async throws -> AuthenticateResponse {
        callback(.oauthAuthenticate)
        return .mock
    }
}

class ThirdPartyOAuthSpy: ThirdPartyOAuthProviderProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func start(parameters: StytchClient.OAuth.ThirdParty.WebAuthSessionStartParameters) async throws -> (token: String, url: URL) {
        callback(.oauthThirdPartyStart)
        return ("", .init(string: "oauth-url")!)
    }
}
