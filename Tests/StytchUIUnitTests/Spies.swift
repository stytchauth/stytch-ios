import Foundation
import StytchCore

enum CalledMethod {
    case magicLinksLoginOrCreate
    case magicLinksSend

    case passwordsCreate
    case passwordsAuthenticate
    case passwordsResetByEmailStart
    case passwordsResetByEmail
    case passwordsStrengthCheck
    case passwordsResetBySession
    case passwordsResetByExistingPassword

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

    func create(parameters _: StytchClient.Passwords.PasswordParameters) async throws -> StytchClient.Passwords.CreateResponse {
        callback(.passwordsCreate)
        return StytchClient.Passwords.CreateResponse.mock
    }

    func authenticate(parameters _: StytchClient.Passwords.PasswordParameters) async throws -> AuthenticateResponse {
        callback(.passwordsAuthenticate)
        return AuthenticateResponse.mock
    }

    func resetByEmailStart(parameters _: StytchClient.Passwords.ResetByEmailStartParameters) async throws -> BasicResponse {
        callback(.passwordsResetByEmailStart)
        return BasicResponse.mock
    }

    func resetByEmail(parameters _: StytchClient.Passwords.ResetByEmailParameters) async throws -> AuthenticateResponse {
        callback(.passwordsResetByEmail)
        return AuthenticateResponse.mock
    }

    func strengthCheck(parameters _: StytchClient.Passwords.StrengthCheckParameters) async throws -> StytchClient.Passwords.StrengthCheckResponse {
        callback(.passwordsStrengthCheck)
        return StytchClient.Passwords.StrengthCheckResponse.successMock
    }

    func resetBySession(parameters _: StytchClient.Passwords.ResetBySessionParameters) async throws -> AuthenticateResponse {
        callback(.passwordsResetBySession)
        return AuthenticateResponse.mock
    }

    func resetByExistingPassword(parameters _: StytchClient.Passwords.ResetByExistingPasswordParameters) async throws -> AuthenticateResponse {
        callback(.passwordsResetByExistingPassword)
        return AuthenticateResponse.mock
    }
}

class MagicLinksSpy: MagicLinksEmailProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func loginOrCreate(parameters _: StytchClient.MagicLinks.Email.Parameters) async throws -> BasicResponse {
        callback(.magicLinksLoginOrCreate)
        return BasicResponse.mock
    }

    func send(parameters _: StytchClient.MagicLinks.Email.Parameters) async throws -> BasicResponse {
        callback(.magicLinksSend)
        return BasicResponse.mock
    }
}

class OTPSpy: OTPProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func loginOrCreate(parameters _: StytchClient.OTP.Parameters) async throws -> StytchClient.OTP.OTPResponse {
        callback(.otpLoginOrCreate)
        return StytchClient.OTP.OTPResponse.mock
    }

    func send(parameters _: StytchClient.OTP.Parameters) async throws -> StytchClient.OTP.OTPResponse {
        callback(.otpSend)
        return StytchClient.OTP.OTPResponse.mock
    }

    func authenticate(parameters _: StytchClient.OTP.AuthenticateParameters) async throws -> AuthenticateResponse {
        callback(.otpAuthenticate)
        return AuthenticateResponse.mock
    }
}

class AppleSpy: AppleOAuthProviderProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func start(parameters _: StytchClient.OAuth.Apple.StartParameters) async throws -> StytchClient.OAuth.Apple.AuthenticateResponse {
        callback(.oauthAppleStart)
        return .mock
    }
}

class OAuthSpy: OAuthProviderProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func authenticate(parameters _: StytchClient.OAuth.AuthenticateParameters) async throws -> AuthenticateResponse {
        callback(.oauthAuthenticate)
        return .mock
    }
}

class ThirdPartyOAuthSpy: ThirdPartyOAuthProviderProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func start(parameters _: StytchClient.OAuth.ThirdParty.WebAuthSessionStartParameters) async throws -> (token: String, url: URL) {
        callback(.oauthThirdPartyStart)
        // swiftlint:disable:next force_unwrapping
        return ("", .init(string: "oauth-url")!)
    }
}
