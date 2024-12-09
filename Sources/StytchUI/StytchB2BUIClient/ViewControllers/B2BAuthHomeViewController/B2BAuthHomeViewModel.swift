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
        Task { [weak self] in
            guard let configuration = self?.state.configuration else {
                return
            }

            switch configuration.authFlowType {
            case .discovery:
                let products = StytchB2BUIClient.productComponentsOrdering(
                    validProducts: configuration.products,
                    configuration: configuration,
                    hasSSOActiveConnections: false
                )
                completion(products)
            case let .organization(slug):
                do {
                    try await OrganizationManager.getOrganizationBySlug(organizationSlug: slug)
                    let validProducts = StytchB2BUIClient.validProducts(
                        organizationAllowedAuthMethods: OrganizationManager.allowedAuthMethods,
                        organizationAuthMethods: OrganizationManager.authMethods,
                        primaryRequired: B2BAuthenticationManager.primaryRequired,
                        configuration: configuration
                    )
                    let products = StytchB2BUIClient.productComponentsOrdering(
                        validProducts: validProducts,
                        configuration: configuration,
                        hasSSOActiveConnections: (OrganizationManager.ssoActiveConnections?.count ?? 0) > 0
                    )
                    completion(products)
                } catch {
                    print(error.errorInfo)
                    completion([])
                }
            }
        }
    }
}

struct B2BAuthHomeState {
    let configuration: StytchB2BUIClient.Configuration
}
