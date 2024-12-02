import Foundation
import StytchCore

protocol B2BAuthHomeViewModelProtocol {
    func logRenderScreen() async throws
}

final class B2BAuthHomeViewModel {
    let state: B2BAuthHomeState

    init(state: B2BAuthHomeState) {
        self.state = state
    }
}

extension B2BAuthHomeViewModel: B2BAuthHomeViewModelProtocol {
    func logRenderScreen() async throws {
        try await EventsClient.logEvent(
            parameters: .init(
                eventName: "render_login_screen",
                details: ["options": String(data: JSONEncoder().encode(state.configuration), encoding: .utf8) ?? ""]
            )
        )
    }

    func loadProducts(
        completion: @escaping ([StytchB2BUIClient.ProductComponent]) -> Void
    ) {
        Task {
            switch state.configuration.authFlowType {
            case .discovery:
                let products = StytchB2BUIClient.productComponentsOrdering(
                    validProducts: state.configuration.products,
                    configuration: state.configuration,
                    hasSSOActiveConnections: false // can you do discovery via sso?
                )
                completion(products)
            case let .organization(slug):
                do {
                    try await OrganizationManager.getOrganizationBySlug(organizationSlug: slug)
                    let validProducts = StytchB2BUIClient.validProducts(
                        organizationAllowedAuthMethods: OrganizationManager.allowedAuthMethods,
                        organizationAuthMethods: OrganizationManager.authMethods,
                        primaryRequired: B2BAuthenticationManager.primaryRequired,
                        configuration: state.configuration
                    )
                    let products = StytchB2BUIClient.productComponentsOrdering(
                        validProducts: validProducts,
                        configuration: state.configuration,
                        hasSSOActiveConnections: (OrganizationManager.ssoActiveConnections?.count ?? 0) > 0
                    )
                    completion(products)
                } catch {
                    print(error.errorInfo)
                    completion([])
                }
            case .passwordReset:
                completion([])
            }
        }
    }
}

struct B2BAuthHomeState {
    let configuration: StytchB2BUIClient.Configuration
}
