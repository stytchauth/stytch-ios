import XCTest
@testable import StytchCore

final class B2BOrganizationsMembersTestCase: BaseTestCase {
    func testCreateMember() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.Members.OrganizationMemberResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(
                    memberId: "member_1234",
                    member: .mock,
                    organization: nil
                )
            )
        }

        let emailAddress = "email@example.com"
        let parameters = StytchB2BClient.Organizations.Members.CreateParameters(emailAddress: emailAddress)
        let createOrganizationMemberResponse = try await StytchB2BClient.organizations.members.create(parameters: parameters)
        XCTAssertEqual(createOrganizationMemberResponse.member.emailAddress, emailAddress)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members",
            method: .post(["email_address": JSON.string(emailAddress)])
        )
    }

    func testUpdateMember() async throws {
        let name = "First Middle Last"
        let memberId = "member_1234"
        networkInterceptor.responses {
            StytchB2BClient.Organizations.Members.OrganizationMemberResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(
                    memberId: memberId,
                    member: .mock,
                    organization: nil
                )
            )
        }

        let parameters = StytchB2BClient.Organizations.Members.UpdateParameters(memberId: "member_1234", name: name)
        let updateOrganizationMemberResponse = try await StytchB2BClient.organizations.members.update(parameters: parameters)
        XCTAssertEqual(updateOrganizationMemberResponse.member.name, name)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/update/\(memberId)",
            method: .put(["member_id": JSON.string(memberId), "name": JSON.string(name)])
        )
    }

    func testDeleteMember() async throws {
        let memberId = "member_1234"
        networkInterceptor.responses {
            StytchB2BClient.Organizations.Members.OrganizationMemberDeleteResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(memberId: memberId)
            )
        }
        let updateOrganizationMemberResponse = try await StytchB2BClient.organizations.members.delete(memberId: memberId)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/\(memberId)",
            method: .delete
        )
    }

    func testReactivateMember() async throws {
        let memberId = "member_1234"
        networkInterceptor.responses {
            StytchB2BClient.Organizations.Members.OrganizationMemberResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(
                    memberId: memberId,
                    member: .mock,
                    organization: nil
                )
            )
        }
        let reactivateOrganizationMemberResponse = try await StytchB2BClient.organizations.members.reactivate(memberId: memberId)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/\(memberId)/reactivate",
            method: .put(JSON.string(memberId))
        )
    }

    func testDeleteFactorTotp() async throws {
        let memberId = "member_1234"
        networkInterceptor.responses {
            StytchB2BClient.Organizations.Members.OrganizationMemberResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(
                    memberId: memberId,
                    member: .mock,
                    organization: nil
                )
            )
        }

        _ = try await StytchB2BClient.organizations.members.deleteFactor(factor: .totp(memberId: memberId))
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/deleteTOTP/\(memberId)",
            method: .delete
        )
    }

    func testDeleteFactorPhoneNumber() async throws {
        let memberId = "member_1234"
        networkInterceptor.responses {
            StytchB2BClient.Organizations.Members.OrganizationMemberResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(
                    memberId: memberId,
                    member: .mock,
                    organization: nil
                )
            )
        }
        _ = try await StytchB2BClient.organizations.members.deleteFactor(factor: .phoneNumber(memberId: memberId))
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/deletePhoneNumber/\(memberId)",
            method: .delete
        )
    }

    func testDeleteFactorPassword() async throws {
        let memberId = "member_1234"
        let passwordId = "password_1234"
        networkInterceptor.responses {
            StytchB2BClient.Organizations.Members.OrganizationMemberResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(
                    memberId: memberId,
                    member: .mock,
                    organization: nil
                )
            )
        }
        _ = try await StytchB2BClient.organizations.members.deleteFactor(factor: .password(passwordId: passwordId))
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/passwords/\(passwordId)",
            method: .delete
        )
    }
}
