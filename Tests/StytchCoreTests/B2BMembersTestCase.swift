import XCTest
@testable import StytchCore

final class B2BMembersTestCase: BaseTestCase {
    func testSync() throws {
        XCTAssertNil(StytchB2BClient.member.getSync())
        Current.localStorage.member = .mock
        XCTAssertNotNil(StytchB2BClient.member.getSync())
    }

    func testGet() async throws {
        networkInterceptor.responses { StytchB2BClient.Members.MemberResponse(requestId: "123", statusCode: 200, wrapped: .init(member: .mock)) }
        XCTAssertNil(StytchB2BClient.member.getSync())
        let getMemberResponse = try await StytchB2BClient.member.get()
        XCTAssertNotNil(StytchB2BClient.member.getSync())
        XCTAssertEqual(getMemberResponse.member.id, StytchB2BClient.member.getSync()?.id)
        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/b2b/organizations/members/me", method: .get)
    }
}
