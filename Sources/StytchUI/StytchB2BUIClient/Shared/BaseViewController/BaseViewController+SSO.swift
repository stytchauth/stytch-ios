import StytchCore
import UIKit

extension BaseViewController {
    func makeSSOButton(ssoActiveConnection: StytchB2BClient.SSOActiveConnection) -> UIControl {
        let button = Button.secondary(
            image: ssoActiveConnection.imageAsset,
            title: LocalizationManager.stytch_b2b_sso_button_title(providerName: ssoActiveConnection.displayName)
        ) {}
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        return button
    }

    func makeSSODiscoveryButton() -> UIControl {
        let button = Button.secondary(
            image: .sso("sso"),
            title: LocalizationManager.stytch_b2b_sso_discovery_button_title
        ) {}
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        return button
    }
}

extension StytchB2BClient.SSOActiveConnection {
    var imageAsset: ImageAsset? {
        if identityProvider == "google-workspace" {
            return .sso("google")
        } else if identityProvider == "microsoft-entra" {
            return .sso("microsoft")
        } else if identityProvider == "okta" {
            return .sso("okta")
        } else {
            return .sso("sso")
        }
    }
}
