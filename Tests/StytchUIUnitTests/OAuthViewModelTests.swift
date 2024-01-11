import XCTest
@testable import StytchCore
@testable import StytchUI

enum OAuthViewModelCalledMethod {
    case appleStart
    case thirdPartyStart
    case authenticate
}

class AppleSpy: AppleOAuthProviderProtocol {
    let callback: (OAuthViewModelCalledMethod) -> Void

    init(callback: @escaping (OAuthViewModelCalledMethod) -> Void) {
        self.callback = callback
    }

    func start(parameters: StytchClient.OAuth.Apple.StartParameters) async throws -> StytchClient.OAuth.Apple.AuthenticateResponse {
        callback(.appleStart)
        return .mock
    }
}

class OAuthSpy: OAuthProviderProtocol {
    let callback: (OAuthViewModelCalledMethod) -> Void

    init(callback: @escaping (OAuthViewModelCalledMethod) -> Void) {
        self.callback = callback
    }

    func authenticate(parameters: StytchClient.OAuth.AuthenticateParameters) async throws -> AuthenticateResponse {
        callback(.authenticate)
        return .mock
    }
}

class ThirdPartyOAuthSpy: ThirdPartyOAuthProviderProtocol {
    let callback: (OAuthViewModelCalledMethod) -> Void

    init(callback: @escaping (OAuthViewModelCalledMethod) -> Void) {
        self.callback = callback
    }

    func start(parameters: StytchClient.OAuth.ThirdParty.WebAuthSessionStartParameters) async throws -> (token: String, url: URL) {
        callback(.thirdPartyStart)
        return ("", .init(string: "oauth-url")!)
    }
}

final class OAuthViewModelTests: BaseTestCase {
    var calledMethods: [OAuthViewModelCalledMethod?] = []
    func calledMethodCallback(method: OAuthViewModelCalledMethod) {
        calledMethods.append(method)
    }

    override func setUp() async throws {
        calledMethods = []
        StytchUIClient.onAuthCallback = nil
    }

    func testSessionDurationMinutesReadsFromConfig() {
        let state = OAuthState(
            config: .init(
                publicToken: "",
                products: .init(),
                session: .init(sessionDuration: 123)
            )
        )
        let vm: OAuthViewModel = OAuthViewModel.init(state: state)
        XCTAssert(vm.sessionDuration.rawValue == 123)
    }

    func testSessionDurationMinutesReadsFromDefaultWhenNotConfigured() {
        let state = OAuthState(
            config: .init(
                publicToken: "",
                products: .init()
            )
        )
        let vm: OAuthViewModel = OAuthViewModel.init(state: state)
        XCTAssert(vm.sessionDuration == Minutes.defaultSessionDuration)
    }

    func testStartOAuthCallsAppleProviderAndCallsAuthCallbackWhenProviderIsApple() async throws {
        let state = OAuthState(
            config: .init(
                publicToken: "",
                products: .init()
            )
        )
        let appleSpy = AppleSpy(callback: calledMethodCallback)
        let vm: OAuthViewModel = OAuthViewModel.init(state: state, appleOAuthProvider: appleSpy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        try await vm.startOAuth(provider: .apple)
        XCTAssert(calledMethods.count == 1)
        XCTAssert(calledMethods.contains(.appleStart))
        XCTAssert(didCallUICallback)
    }

    func testStartOAuthDoesNothingIfOAuthIsNotConfiguredAndProviderIsThirdParty() async throws {
        let state = OAuthState(
            config: .init(
                publicToken: "",
                products: .init()
            )
        )
        let appleSpy = AppleSpy(callback: calledMethodCallback)
        let oAuthSpy = OAuthSpy(callback: calledMethodCallback)
        let thirdPartySpy = ThirdPartyOAuthSpy(callback: calledMethodCallback)
        let vm: OAuthViewModel = OAuthViewModel.init(state: state, appleOAuthProvider: appleSpy, oAuthProvider: oAuthSpy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        try await vm.startOAuth(provider: .thirdParty(.amazon), thirdPartyClientForTesting: thirdPartySpy)
        XCTAssert(calledMethods.count == 0)
        XCTAssert(!didCallUICallback)
    }

    func testStartOAuthCallsThirdPartyStartAndAuthenticateFlowAndReportsToUIIfOAuthIsConfiguredAndProviderIsThirdParty() async throws {
        let state = OAuthState(
            config: .init(
                publicToken: "",
                products: .init(
                    oauth: .init(
                        providers: [.thirdParty(.amazon)],
                        loginRedirectUrl: .init(string: "oauth://login")!,
                        signupRedirectUrl: .init(string: "oauth://signup")!
                    )
                )
            )
        )
        let appleSpy = AppleSpy(callback: calledMethodCallback)
        let oAuthSpy = OAuthSpy(callback: calledMethodCallback)
        let thirdPartySpy = ThirdPartyOAuthSpy(callback: calledMethodCallback)
        let vm: OAuthViewModel = OAuthViewModel.init(state: state, appleOAuthProvider: appleSpy, oAuthProvider: oAuthSpy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        try await vm.startOAuth(provider: .thirdParty(.amazon), thirdPartyClientForTesting: thirdPartySpy)
        XCTAssert(calledMethods.count == 2)
        XCTAssert(calledMethods.contains(.thirdPartyStart))
        XCTAssert(calledMethods.contains(.authenticate))
        XCTAssert(didCallUICallback)
    }
}
