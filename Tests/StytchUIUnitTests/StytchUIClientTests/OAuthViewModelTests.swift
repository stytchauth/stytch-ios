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
    }

    func testSessionDurationMinutesReadsFromConfig() {
        let state = OAuthState(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: []
            )
        )
        _ = OAuthViewModel(state: state)
        XCTAssert(state.config.stytchClientConfiguration.defaultSessionDuration == 5)
    }

    func testStartOAuthCallsAppleProviderAndCallsAuthCallbackWhenProviderIsApple() async throws {
        let state = OAuthState(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: [.oauth],
                oauthProviders: [.apple]
            )
        )
        let appleSpy = AppleSpy(callback: calledMethodCallback)
        let viewModel = OAuthViewModel(state: state, appleOAuthProvider: appleSpy)
        try await viewModel.startOAuth(provider: .apple)
        XCTAssert(calledMethods.count == 1)
        XCTAssert(calledMethods.contains(.oauthAppleStart))
    }

    func testStartOAuthDoesNothingIfOAuthIsNotConfiguredAndProviderIsThirdParty() async throws {
        let state = OAuthState(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: [],
                oauthProviders: []
            )
        )
        let appleSpy = AppleSpy(callback: calledMethodCallback)
        let oAuthSpy = OAuthSpy(callback: calledMethodCallback)
        let thirdPartySpy = ThirdPartyOAuthSpy(callback: calledMethodCallback)
        let viewModel = OAuthViewModel(state: state, appleOAuthProvider: appleSpy, oAuthProvider: oAuthSpy)
        try await viewModel.startOAuth(provider: .thirdParty(.amazon), thirdPartyClientForTesting: thirdPartySpy)
        XCTAssert(calledMethods.isEmpty)
    }

    func testStartOAuthCallsThirdPartyStartAndAuthenticateFlowAndReportsToUIIfOAuthIsConfiguredAndProviderIsThirdParty() async throws {
        let state = OAuthState(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
                products: [.oauth],
                oauthProviders: [.thirdParty(.amazon)]
            )
        )
        let appleSpy = AppleSpy(callback: calledMethodCallback)
        let oAuthSpy = OAuthSpy(callback: calledMethodCallback)
        let thirdPartySpy = ThirdPartyOAuthSpy(callback: calledMethodCallback)
        let viewModel = OAuthViewModel(state: state, appleOAuthProvider: appleSpy, oAuthProvider: oAuthSpy)
        try await viewModel.startOAuth(provider: .thirdParty(.amazon), thirdPartyClientForTesting: thirdPartySpy)
        XCTAssert(calledMethods.count == 2)
        XCTAssert(calledMethods.contains(.oauthThirdPartyStart))
        XCTAssert(calledMethods.contains(.oauthAuthenticate))
    }
}
