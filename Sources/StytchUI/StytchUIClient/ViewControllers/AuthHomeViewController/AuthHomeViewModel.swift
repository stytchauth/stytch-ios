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

        for component in state.config.products {
            switch component {
            case .emailMagicLinks, .passwords, .otp:
                productComponents.appendIfNotPresent(.inputProducts)
            case .oauth:
                if state.config.supportsBiometricsAndOAuth {
                    productComponents.appendIfNotPresent(.oAuthButtons)
                    productComponents.appendIfNotPresent(.biometrics)
                } else {
                    productComponents.appendIfNotPresent(.oAuthButtons)
                }
            case .biometrics:
                if state.config.supportsBiometricsAndOAuth {
                    productComponents.appendIfNotPresent(.biometrics)
                    productComponents.appendIfNotPresent(.oAuthButtons)
                } else {
                    productComponents.appendIfNotPresent(.biometrics)
                }
            }
        }

        let shouldShowBiometrics = StytchClient.biometrics.availability.isAvailableRegistered && state.config.supportsBiometrics

        if state.config.supportsInputProducts, state.config.supportsOauth || shouldShowBiometrics {
            if let index = productComponents.firstIndex(of: .inputProducts) {
                if index == 0 {
                    productComponents.insert(.divider, at: 1)
                } else {
                    productComponents.insert(.divider, at: index)
                }
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
                details: [
                    "options": String(data: JSONEncoder().encode(state.config), encoding: .utf8) ?? "",
                    "bootstrap": String(data: JSONEncoder().encode(StytchClient.bootstrapData), encoding: .utf8) ?? "",
                ]
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
