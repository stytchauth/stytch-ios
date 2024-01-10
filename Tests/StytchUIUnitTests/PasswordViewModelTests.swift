import XCTest
@testable import StytchCore
@testable import StytchUI

enum CalledMethod {
    case create
    case authenticate
    case resetByEmailStart
    case resetByEmail
    case strengthCheck
    case resetBySession
    case magicLinksLoginOrCreate
    case magicLinksSend
}

class PasswordsSpy: PasswordsProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func create(parameters: StytchCore.StytchClient.Passwords.PasswordParameters) async throws -> StytchClient.Passwords.CreateResponse {
        callback(.create)
        return StytchClient.Passwords.CreateResponse.mock
    }
    
    func authenticate(parameters: StytchCore.StytchClient.Passwords.PasswordParameters) async throws -> AuthenticateResponse {
        callback(.authenticate)
        return AuthenticateResponse.mock
    }
    
    func resetByEmailStart(parameters: StytchCore.StytchClient.Passwords.ResetByEmailStartParameters) async throws -> BasicResponse {
        callback(.resetByEmailStart)
        return BasicResponse.mock
    }
    
    func resetByEmail(parameters: StytchCore.StytchClient.Passwords.ResetByEmailParameters) async throws -> AuthenticateResponse {
        callback(.resetByEmail)
        return AuthenticateResponse.mock
    }
    
    func strengthCheck(parameters: StytchCore.StytchClient.Passwords.StrengthCheckParameters) async throws -> StytchClient.Passwords.StrengthCheckResponse {
        callback(.strengthCheck)
        return StytchClient.Passwords.StrengthCheckResponse.successMock
    }
    
    func resetBySession(parameters: StytchCore.StytchClient.Passwords.ResetBySessionParameters) async throws -> AuthenticateResponse {
        callback(.resetBySession)
        return AuthenticateResponse.mock
    }
}

class MagicLinksSpy: MagicLinksEmailProtocol {
    let callback: (CalledMethod) -> Void

    init(callback: @escaping (CalledMethod) -> Void) {
        self.callback = callback
    }

    func loginOrCreate(parameters: StytchCore.StytchClient.MagicLinks.Email.Parameters) async throws -> BasicResponse {
        callback(.magicLinksLoginOrCreate)
        return BasicResponse.mock
    }
    
    func send(parameters: StytchCore.StytchClient.MagicLinks.Email.Parameters) async throws -> BasicResponse {
        callback(.magicLinksSend)
        return BasicResponse.mock
    }
}

final class PasswordViewModelTests: BaseTestCase {
    override func setUp() async throws {
        calledMethod = nil
        StytchUIClient.onAuthCallback = nil
        StytchUIClient.pendingResetEmail = nil
    }

    func testSessionDurationMinutesReadsFromConfig() {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init(),
                session: .init(sessionDuration: 123)
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let vm: PasswordViewModel = PasswordViewModel.init(state: state)
        XCTAssert(vm.sessionDuration.rawValue == 123)
    }

    func testSessionDurationMinutesReadsFromDefaultWhenNotConfigured() {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let vm: PasswordViewModel = PasswordViewModel.init(state: state)
        XCTAssert(vm.sessionDuration.rawValue == Minutes.defaultSessionDuration.rawValue)
    }

    func testCreatesCorrectResetByEmailStartParams() {
        let passwordConfig: StytchUIClient.Configuration.Password = .init(
            loginURL: .init(string: "myapp://test-login"),
            loginExpiration: 123,
            resetPasswordURL: .init(string: "myapp://test-reset"),
            resetPasswordExpiration: 456,
            resetPasswordTemplateId: "reset-password-template-id"
        )
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let vm: PasswordViewModel = PasswordViewModel.init(state: state)
        let expected: StytchClient.Passwords.ResetByEmailStartParameters = .init(
            email: "test@stytch.com",
            loginUrl: passwordConfig.loginURL,
            loginExpiration: passwordConfig.loginExpiration,
            resetPasswordUrl: passwordConfig.resetPasswordURL,
            resetPasswordExpiration: passwordConfig.resetPasswordExpiration,
            resetPasswordTemplateId: passwordConfig.resetPasswordTemplateId
        )
        let result = vm.params(email: "test@stytch.com", password: passwordConfig)
        XCTAssert(result == expected)
    }
    
    func testCreatesCorrectMagicLinkParams() {
        let magicLinkConfig: StytchUIClient.Configuration.MagicLink = .init(
            loginMagicLinkUrl: .init(string: "myapp://test-login"),
            loginExpiration: 123,
            loginTemplateId: "login-template-id",
            signupMagicLinkUrl: .init(string: "myapp://test-signup"),
            signupExpiration: 456,
            signupTemplateId: "signup-template-id"
        )
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let vm: PasswordViewModel = PasswordViewModel.init(state: state)
        let expected: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "test@stytch.com",
            loginMagicLinkUrl: magicLinkConfig.loginMagicLinkUrl,
            loginExpiration: magicLinkConfig.loginExpiration,
            loginTemplateId: magicLinkConfig.loginTemplateId,
            signupMagicLinkUrl: magicLinkConfig.signupMagicLinkUrl,
            signupExpiration: magicLinkConfig.signupExpiration,
            signupTemplateId: magicLinkConfig.signupTemplateId
        )
        let result = vm.params(email: "test@stytch.com", magicLink: magicLinkConfig)
        XCTAssert(result == expected)
    }

    
    var calledMethod: CalledMethod? = nil
    func calledMethodCallback(method: CalledMethod) {
        calledMethod = method
    }

    func testCheckStrengthCallsStrengthCheck() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let vm: PasswordViewModel = PasswordViewModel.init(state: state, passwordClient: spy)
        _ = try await vm.checkStrength(email: "test@stytch.com", password: "password")
        XCTAssert(calledMethod == CalledMethod.strengthCheck)
    }

    func testSetPasswordCallsResetByEmailAndReportsToOnAuthCallback() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let vm: PasswordViewModel = PasswordViewModel.init(state: state, passwordClient: spy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        _ = try await vm.setPassword(token: "", password: "")
        XCTAssert(calledMethod == CalledMethod.resetByEmail)
        XCTAssert(didCallUICallback)
    }

    func testSignupCallsCreateAndReportsToOnAuthCallback() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let vm: PasswordViewModel = PasswordViewModel.init(state: state, passwordClient: spy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        _ = try await vm.signup(email: "", password: "")
        XCTAssert(calledMethod == CalledMethod.create)
        XCTAssert(didCallUICallback)
    }

    func testLoginCallsAuthenticateAndReportsToOnAuthCallback() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let vm: PasswordViewModel = PasswordViewModel.init(state: state, passwordClient: spy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        _ = try await vm.login(email: "", password: "")
        XCTAssert(calledMethod == CalledMethod.authenticate)
        XCTAssert(didCallUICallback)
    }

    func testLoginWithEmailExitsEarlyWhenEMLProductIsNotConfigured() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: MagicLinksEmailProtocol = MagicLinksSpy(callback: calledMethodCallback)
        let vm: PasswordViewModel = PasswordViewModel.init(state: state, magicLinksClient: spy)
        _ = try await vm.loginWithEmail(email: "")
        XCTAssert(calledMethod == nil)
    }

    func testLoginWithEmailCallsLoginOrCreateWhenEMLProductIsConfigured() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init(
                    magicLink: .init()
                )
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: MagicLinksEmailProtocol = MagicLinksSpy(callback: calledMethodCallback)
        let vm: PasswordViewModel = PasswordViewModel.init(state: state, magicLinksClient: spy)
        _ = try await vm.loginWithEmail(email: "")
        XCTAssert(calledMethod == CalledMethod.magicLinksLoginOrCreate)
    }

    func testForgotPasswordExitsEarlyWhenPasswordProductIsNotConfigured() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let vm: PasswordViewModel = PasswordViewModel.init(state: state, passwordClient: spy)
        _ = try await vm.forgotPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == nil)
        XCTAssert(StytchUIClient.pendingResetEmail == nil)
    }

    func testForgotPasswordCallsResetByEmailStartAndSetsPendingResetEmailWhenPasswordProductIsConfigured() async throws {
        let state = PasswordState(
            config: .init(
                publicToken: "",
                products: .init(
                    password: .init()
                )
            ),
            intent: PasswordState.Intent.login,
            email: "",
            magicLinksEnabled: true
        )
        let spy: PasswordsProtocol = PasswordsSpy(callback: calledMethodCallback)
        let vm: PasswordViewModel = PasswordViewModel.init(state: state, passwordClient: spy)
        _ = try await vm.forgotPassword(email: "test@stytch.com")
        XCTAssert(calledMethod == CalledMethod.resetByEmailStart)
        XCTAssert(StytchUIClient.pendingResetEmail == "test@stytch.com")
    }
}
