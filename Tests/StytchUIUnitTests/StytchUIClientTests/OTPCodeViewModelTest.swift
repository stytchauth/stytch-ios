import XCTest
@testable import StytchCore
@testable import StytchUI

final class OTPCodeViewModelTest: BaseTestCase {
    var calledMethod: CalledMethod?

    func calledMethodCallback(method: CalledMethod) {
        calledMethod = method
    }

    override func setUp() async throws {
        try await super.setUp()
        calledMethod = nil
    }

    func testResendCodeCallsLoginOrCreateAndUpdatesState() async throws {
        let state: OTPCodeState = .init(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: [.otp]
            ),
            otpMethod: .sms,
            input: "",
            formattedInput: "",
            methodId: "",
            codeExpiry: Date(),
            passwordsEnabled: false
        )
        let spy = OTPSpy(callback: calledMethodCallback)
        let viewModel: OTPCodeViewModel = .init(state: state, otpClient: spy)
        _ = try await viewModel.resendCode(input: "1234567890")
        XCTAssert(calledMethod == .otpLoginOrCreate)
        XCTAssert(viewModel.state.input == "1234567890")
        XCTAssert(viewModel.state.methodId == "otp-method-id")
    }

    func testEnterCodeCallsAuthenticateAndReportsToUICallback() async throws {
        let state: OTPCodeState = .init(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: [.otp]
            ),
            otpMethod: .sms,
            input: "",
            formattedInput: "",
            methodId: "",
            codeExpiry: Date(),
            passwordsEnabled: false
        )
        let spy = OTPSpy(callback: calledMethodCallback)
        let viewModel: OTPCodeViewModel = .init(state: state, otpClient: spy)
        _ = try await viewModel.enterCode(code: "123456", methodId: "")
        XCTAssert(calledMethod == .otpAuthenticate)
    }
}
