import XCTest
@testable import StytchCore
@testable import StytchUI

enum OTPCodeViewModelCalledMethod {
    case loginOrCreate
    case send
    case authenticate
}

class OTPSpy: OTPProtocol {
    func loginOrCreate(parameters: StytchClient.OTP.Parameters) async throws -> StytchClient.OTP.OTPResponse {
        callback(.loginOrCreate)
        return StytchClient.OTP.OTPResponse.mock
    }
    
    func send(parameters: StytchClient.OTP.Parameters) async throws -> StytchClient.OTP.OTPResponse {
        callback(.send)
        return StytchClient.OTP.OTPResponse.mock
    }
    
    func authenticate(parameters: StytchClient.OTP.AuthenticateParameters) async throws -> AuthenticateResponse {
        callback(.authenticate)
        return AuthenticateResponse.mock
    }
    
    let callback: (OTPCodeViewModelCalledMethod) -> Void
    
    init(callback: @escaping (OTPCodeViewModelCalledMethod) -> Void) {
        self.callback = callback
    }
}

final class OTPCodeViewModelTest: BaseTestCase {
    var calledMethod: OTPCodeViewModelCalledMethod? = nil
    func calledMethodCallback(method: OTPCodeViewModelCalledMethod) {
        calledMethod = method
    }
    
    override func setUp() async throws {
        calledMethod = nil
        StytchUIClient.onAuthCallback = nil
    }

    func testResendCodeCallsLoginOrCreateAndUpdatesState() async throws {
        let state: OTPCodeState = .init(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            phoneNumberE164: "",
            formattedPhoneNumber: "",
            methodId: "",
            codeExpiry: Date()
        )
        let spy = OTPSpy(callback: calledMethodCallback)
        let vm: OTPCodeViewModel = .init(state: state, otpClient: spy)
        _ = try await vm.resendCode(phone: "1234567890")
        XCTAssert(calledMethod == OTPCodeViewModelCalledMethod.loginOrCreate)
        XCTAssert(vm.state.phoneNumberE164 == "1234567890")
        XCTAssert(vm.state.methodId == "otp-method-id")
    }

    func testEnterCodeCallsAuthenticateAndReportsToUICallback() async throws {
        let state: OTPCodeState = .init(
            config: .init(
                publicToken: "",
                products: .init()
            ),
            phoneNumberE164: "",
            formattedPhoneNumber: "",
            methodId: "",
            codeExpiry: Date()
        )
        let spy = OTPSpy(callback: calledMethodCallback)
        let vm: OTPCodeViewModel = .init(state: state, otpClient: spy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        _ = try await vm.enterCode(code: "123456", methodId: "")
        XCTAssert(calledMethod == OTPCodeViewModelCalledMethod.authenticate)
        XCTAssert(didCallUICallback)
    }
}
