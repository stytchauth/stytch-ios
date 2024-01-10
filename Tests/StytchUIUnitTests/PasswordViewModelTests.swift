import XCTest
@testable import StytchCore
@testable import StytchUI

class PasswordsSpy: PasswordsProtocol {
    enum CalledMethod {
        case create
        case authenticate
        case resetByEmailStart
        case resetByEmail
        case strengthCheck
        case resetBySession
    }

    var calledMethod: CalledMethod? = nil

    func create(parameters: StytchCore.StytchClient.Passwords.PasswordParameters) async throws -> StytchClient.Passwords.CreateResponse {
        calledMethod = .create
        return StytchClient.Passwords.CreateResponse.mock
    }
    
    func authenticate(parameters: StytchCore.StytchClient.Passwords.PasswordParameters) async throws -> AuthenticateResponse {
        calledMethod = .authenticate
        return AuthenticateResponse.mock
    }
    
    func resetByEmailStart(parameters: StytchCore.StytchClient.Passwords.ResetByEmailStartParameters) async throws -> BasicResponse {
        calledMethod = .resetByEmailStart
        return BasicResponse.mock
    }
    
    func resetByEmail(parameters: StytchCore.StytchClient.Passwords.ResetByEmailParameters) async throws -> AuthenticateResponse {
        calledMethod = .resetByEmail
        return AuthenticateResponse.mock
    }
    
    func strengthCheck(parameters: StytchCore.StytchClient.Passwords.StrengthCheckParameters) async throws -> StytchClient.Passwords.StrengthCheckResponse {
        calledMethod = .strengthCheck
        return StytchClient.Passwords.StrengthCheckResponse.successMock
    }
    
    func resetBySession(parameters: StytchCore.StytchClient.Passwords.ResetBySessionParameters) async throws -> AuthenticateResponse {
        calledMethod = .resetBySession
        return AuthenticateResponse.mock
    }
    
    
}

final class PasswordViewModelTests: BaseTestCase {
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
}
