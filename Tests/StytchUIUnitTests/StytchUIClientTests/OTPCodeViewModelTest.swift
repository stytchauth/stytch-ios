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
        StytchUIClient.onAuthCallback = nil
    }

    func testResendCodeCallsLoginOrCreateAndUpdatesState() async throws {
        let state: OTPCodeState = .init(
            config: .init(
                publicToken: "publicToken",
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
                publicToken: "publicToken",
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
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        _ = try await viewModel.enterCode(code: "123456", methodId: "")
        XCTAssert(calledMethod == .otpAuthenticate)
        XCTAssert(didCallUICallback)
    }
}
