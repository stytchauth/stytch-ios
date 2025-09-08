import Foundation
import StytchCore

final class B2BAuthHomeViewModel {
    let state: B2BAuthHomeState

    init(state: B2BAuthHomeState) {
        self.state = state
    }

    func logRenderScreen() async throws {
        try await EventsClient.logEvent(
            parameters: .init(
                eventName: "render_b2b_login_screen",
                details: [
                    "options": String(data: JSONEncoder().encode(state.configuration), encoding: .utf8) ?? "",
                    "bootstrap": String(data: JSONEncoder().encode(StytchB2BClient.bootstrapData), encoding: .utf8) ?? "",
                ]
            )
        )
    }

    func loadProducts(
        completion: @escaping ([StytchB2BUIClient.ProductComponent], Error?) -> Void
    ) {
        Task {
            switch state.configuration.computedAuthFlowType {
            case .discovery:
                let products = StytchB2BUIClient.productComponentsOrdering(
                    validProducts: state.configuration.products,
                    configuration: state.configuration,
                    hasSSOActiveConnections: false // can you do discovery via sso?
                )
                completion(products, nil)
            case let .organization(slug):
                do {
                    if OrganizationManager.organizationId == nil {
                        try await OrganizationManager.getOrganizationBySlug(organizationSlug: slug)
                    }
                    completion(products(), nil)
                } catch {
                    completion([], error)
                }
            }
        }
    }

    func products() -> [StytchB2BUIClient.ProductComponent] {
        let validProducts = StytchB2BUIClient.validProducts(
            organizationAllowedAuthMethods: OrganizationManager.allowedAuthMethods,
            organizationAuthMethods: OrganizationManager.authMethods,
            primaryRequired: B2BAuthenticationManager.primaryRequired,
            configurationProducts: state.configuration.products,
            oauthProviders: state.configuration.oauthProviders
        )
        let products = StytchB2BUIClient.productComponentsOrdering(
            validProducts: validProducts,
            configuration: state.configuration,
            hasSSOActiveConnections: (OrganizationManager.ssoActiveConnections?.count ?? 0) > 0
        )
        return products
    }
}

struct B2BAuthHomeState {
    let configuration: StytchB2BUIClient.Configuration
}
