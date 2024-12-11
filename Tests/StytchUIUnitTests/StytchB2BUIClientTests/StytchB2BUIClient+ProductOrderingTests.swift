import XCTest
@testable import StytchCore
@testable import StytchUI

final class ProductOrderingTests: B2BBaseTestCase {
    func configuration(
        products: [StytchB2BUIClient.B2BProducts],
        authFlowType: StytchB2BUIClient.AuthFlowType
    ) -> StytchB2BUIClient.Configuration {
        .init(
            publicToken: "public-token",
            hostUrl: nil,
            products: products,
            authFlowType: authFlowType,
            sessionDurationMinutes: .defaultSessionDuration,
            emailMagicLinksOptions: nil,
            passwordOptions: nil,
            oauthProviders: [],
            emailOtpOptions: nil,
            directLoginForSingleMembershipOptions: nil,
            disableCreateOrganization: nil,
            mfaProductOrder: nil,
            mfaProductInclude: nil,
            navigation: nil,
            theme: StytchTheme()
        )
    }
}
