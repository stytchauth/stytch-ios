import Foundation
import StytchCore

protocol AuthHomeViewModelProtocol {
    func logRenderScreen() async throws
    func checkValidConfig() throws
}

final class AuthHomeViewModel {
    let state: AuthHomeState

    init(state: AuthHomeState) {
        self.state = state
    }
}

extension AuthHomeViewModel {
    var productComponents: [StytchUIClient.ProductComponent] {
        var productComponents = [StytchUIClient.ProductComponent]()
        var hasBiometrics = false

        for component in state.config.products {
            switch component {
            case .biometrics:
                productComponents.appendIfNotPresent(.biometrics)
                hasBiometrics = true
            case .oauth:
                if !productComponents.contains(.oAuthButtons) {
                    productComponents.append(.oAuthButtons)
                }
            case .emailMagicLinks, .passwords, .otp:
                if !productComponents.contains(.inputProducts) {
                    productComponents.append(.inputProducts)
                }
            }
        }

        if hasBiometrics {
            if let biometricsIndex = productComponents.firstIndex(of: .biometrics) {
                productComponents.insert(.divider, at: biometricsIndex)
            }
        }

        return productComponents
    }
}

extension AuthHomeViewModel: AuthHomeViewModelProtocol {
    func logRenderScreen() async throws {
        try await EventsClient.logEvent(
            parameters: .init(
                eventName: "render_login_screen",
                details: ["options": String(data: JSONEncoder().encode(state.config), encoding: .utf8) ?? ""]
            )
        )
    }

    func checkValidConfig() throws {
        if state.config.supportsEmailMagicLinks, let otp = state.config.otpOptions, otp.methods.contains(.email) {
            throw StytchSDKError.uiEmlAndOtpInvalid
        }
    }
}

struct AuthHomeState {
    let config: StytchUIClient.Configuration
}

extension StytchUIClient {
    enum ProductComponent: String, Equatable {
        case inputProducts
        case oAuthButtons
        case biometrics
        case divider
    }
}
