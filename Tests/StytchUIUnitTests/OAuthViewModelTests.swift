import XCTest
@testable import StytchCore
@testable import StytchUI

final class OAuthViewModelTests: BaseTestCase {
    var calledMethods: [CalledMethod?] = []

    func calledMethodCallback(method: CalledMethod) {
        calledMethods.append(method)
    }

    override func setUp() async throws {
        try await super.setUp()
        calledMethods = []
        StytchUIClient.onAuthCallback = nil
    }

    func testSessionDurationMinutesReadsFromConfig() {
        let state = OAuthState(
            config: .init(
                products: .init(),
                session: .init(sessionDuration: 123)
            )
        )
        let viewModel = OAuthViewModel(state: state)
        XCTAssert(viewModel.sessionDuration.rawValue == 123)
    }

    func testSessionDurationMinutesReadsFromDefaultWhenNotConfigured() {
        let state = OAuthState(
            config: .init(
                products: .init()
            )
        )
        let viewModel = OAuthViewModel(state: state)
        XCTAssert(viewModel.sessionDuration == Minutes.defaultSessionDuration)
    }

    func testStartOAuthCallsAppleProviderAndCallsAuthCallbackWhenProviderIsApple() async throws {
        let state = OAuthState(
            config: .init(
                products: .init()
            )
        )
        let appleSpy = AppleSpy(callback: calledMethodCallback)
        let viewModel = OAuthViewModel(state: state, appleOAuthProvider: appleSpy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        try await viewModel.startOAuth(provider: .apple)
        XCTAssert(calledMethods.count == 1)
        XCTAssert(calledMethods.contains(.oauthAppleStart))
        XCTAssert(didCallUICallback)
    }

    func testStartOAuthDoesNothingIfOAuthIsNotConfiguredAndProviderIsThirdParty() async throws {
        let state = OAuthState(
            config: .init(
                products: .init()
            )
        )
        let appleSpy = AppleSpy(callback: calledMethodCallback)
        let oAuthSpy = OAuthSpy(callback: calledMethodCallback)
        let thirdPartySpy = ThirdPartyOAuthSpy(callback: calledMethodCallback)
        let viewModel = OAuthViewModel(state: state, appleOAuthProvider: appleSpy, oAuthProvider: oAuthSpy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        try await viewModel.startOAuth(provider: .thirdParty(.amazon), thirdPartyClientForTesting: thirdPartySpy)
        XCTAssert(calledMethods.isEmpty)
        XCTAssert(!didCallUICallback)
    }

    func testStartOAuthCallsThirdPartyStartAndAuthenticateFlowAndReportsToUIIfOAuthIsConfiguredAndProviderIsThirdParty() async throws {
        let state = OAuthState(
            config: .init(
                products: .init(
                    oauth: .init(
                        providers: [.thirdParty(.amazon)],
                        // swiftlint:disable:next force_unwrapping
                        loginRedirectUrl: .init(string: "oauth://login")!,
                        // swiftlint:disable:next force_unwrapping
                        signupRedirectUrl: .init(string: "oauth://signup")!
                    )
                )
            )
        )
        let appleSpy = AppleSpy(callback: calledMethodCallback)
        let oAuthSpy = OAuthSpy(callback: calledMethodCallback)
        let thirdPartySpy = ThirdPartyOAuthSpy(callback: calledMethodCallback)
        let viewModel = OAuthViewModel(state: state, appleOAuthProvider: appleSpy, oAuthProvider: oAuthSpy)
        var didCallUICallback = false
        StytchUIClient.onAuthCallback = { _ in
            didCallUICallback = true
        }
        try await viewModel.startOAuth(provider: .thirdParty(.amazon), thirdPartyClientForTesting: thirdPartySpy)
        XCTAssert(calledMethods.count == 2)
        XCTAssert(calledMethods.contains(.oauthThirdPartyStart))
        XCTAssert(calledMethods.contains(.oauthAuthenticate))
        XCTAssert(didCallUICallback)
    }
}
