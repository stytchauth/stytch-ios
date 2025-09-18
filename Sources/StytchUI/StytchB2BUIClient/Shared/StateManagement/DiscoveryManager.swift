import StytchCore
import UIKit

struct DiscoveryManager {
    private(set) static var discoveredOrganizations: [StytchB2BClient.DiscoveredOrganization] = []

    static func updateDiscoveredOrganizations(newDiscoveredOrganizations: [StytchB2BClient.DiscoveredOrganization]) {
        discoveredOrganizations = newDiscoveredOrganizations
    }

    static func selectDiscoveredOrganization(discoveredOrganization: StytchB2BClient.DiscoveredOrganization) async throws {
        let response = try await StytchB2BClient.discovery.exchangeIntermediateSession(
            parameters: .init(
                organizationId: discoveredOrganization.organization.organizationId
            )
        )
        B2BAuthenticationManager.handlePrimaryMFAReponse(b2bMFAAuthenticateResponse: response)
    }

    static func reset() {
        discoveredOrganizations = []
    }
}

// Determine if a single discovered organization exsists
extension Array where Element == StytchB2BClient.DiscoveredOrganization {
    func shouldAllowDirectLoginToOrganization(_ directLoginForSingleMembershipOptions: StytchB2BUIClient.DirectLoginForSingleMembershipOptions? = nil) -> StytchB2BClient.DiscoveredOrganization? {
        let invitedTypes: [StytchB2BClient.MembershipType] = [.pendingMember, .invitedMember]
        let jitEligible: [StytchB2BClient.MembershipType] = [.eligibleToJoinByEmailDomain, .eligibleToJoinByOauthTenant]

        // If direct login is not enabled, return nil
        guard let directLoginForSingleMembershipOptions = directLoginForSingleMembershipOptions else {
            return nil
        }

        // Count active memberships
        let activeOrganizations = filter { org in
            org.membership.type == .activeMember
        }

        // Check for pending invites or JIT provisioning, depending on config
        let hasBlockingConditions = contains { org in
            (invitedTypes.contains(org.membership.type) && !directLoginForSingleMembershipOptions.ignoreInvites) ||
                (jitEligible.contains(org.membership.type) && !directLoginForSingleMembershipOptions.ignoreJitProvisioning)
        }

        // Allow direct login if there is exactly one active membership and no blocking conditions
        if activeOrganizations.count == 1, !hasBlockingConditions {
            return activeOrganizations[0]
        }

        return nil
    }
}
