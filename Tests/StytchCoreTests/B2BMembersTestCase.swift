import Combine
import XCTest
@testable import StytchCore

// swiftlint:disable implicitly_unwrapped_optional
// swiftlint:disable multiline_function_chains

final class B2BMembersTestCase: BaseTestCase {
    var subscriptions: Set<AnyCancellable> = []

    var response: StytchB2BClient.Members.MemberResponse!

    override func setUpWithError() throws {
        try super.setUpWithError()

        response = StytchB2BClient.Members.MemberResponse(
            requestId: "123",
            statusCode: 200,
            wrapped: .init(
                memberId: "member_1234",
                member: .mock,
                organization: nil
            )
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        response = nil
    }

    func testSync() throws {
        XCTAssertNil(StytchB2BClient.member.getSync())
        Current.memberStorage.update(.mock)
        XCTAssertNotNil(StytchB2BClient.member.getSync())
    }

    func testGet() async throws {
        networkInterceptor.responses {
            response
        }
        XCTAssertNil(StytchB2BClient.member.getSync())
        let getMemberResponse = try await StytchB2BClient.member.get()
        XCTAssertNotNil(StytchB2BClient.member.getSync())
        XCTAssertEqual(getMemberResponse.member.id, StytchB2BClient.member.getSync()?.id)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/me",
            method: .get
        )
    }

    func testUpdate() async throws {
        networkInterceptor.responses {
            response
        }
        XCTAssertNil(StytchB2BClient.member.getSync())
        let updateMemberResponse = try await StytchB2BClient.member.update(parameters: .init(name: "foo bar", untrustedMetadata: ["blah": 1]))
        XCTAssertNotNil(StytchB2BClient.member.getSync())
        XCTAssertEqual(updateMemberResponse.memberId, StytchB2BClient.member.getSync()?.memberId.rawValue)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/update",
            method: .put(["name": "foo bar", "untrusted_metadata": ["blah": 1]])
        )
    }

    func testDeletePhoneNumberFactor() async throws {
        networkInterceptor.responses {
            response
        }
        Current.memberStorage.update(nil)
        XCTAssertNil(StytchB2BClient.member.getSync())
        _ = try await StytchB2BClient.member.deleteFactor(.phoneNumber)
        XCTAssertNotNil(StytchB2BClient.member.getSync())
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/deletePhoneNumber",
            method: .delete
        )
    }

    func testDeleteTotpFactor() async throws {
        networkInterceptor.responses {
            response
        }
        Current.memberStorage.update(nil)
        XCTAssertNil(StytchB2BClient.member.getSync())
        _ = try await StytchB2BClient.member.deleteFactor(.totp)
        XCTAssertNotNil(StytchB2BClient.member.getSync())
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/deleteTOTP",
            method: .delete
        )
    }

    func testDeletePasswordFactor() async throws {
        networkInterceptor.responses {
            response
        }
        Current.memberStorage.update(nil)
        XCTAssertNil(StytchB2BClient.member.getSync())
        _ = try await StytchB2BClient.member.deleteFactor(.password(passwordId: "passwordId-1234"))
        XCTAssertNotNil(StytchB2BClient.member.getSync())
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/passwords/passwordId-1234",
            method: .delete
        )
    }

    func testMemberPublisherAvailable() throws {
        let expectation = XCTestExpectation(description: "onMemberChange completes")
        var receivedMember: Member?
        var receivedDate: Date?

        StytchB2BClient.member.onMemberChange.sink { memberInfo in
            switch memberInfo {
            case let .available(member, lastValidatedAtDate):
                receivedMember = member
                receivedDate = lastValidatedAtDate
                expectation.fulfill()
            case .unavailable:
                break
            }
        }.store(in: &subscriptions)

        Current.memberStorage.update(.mock)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedMember)
        XCTAssertNotNil(receivedDate)
    }

    func testMemberPublisherUnavailable() throws {
        let expectation = XCTestExpectation(description: "onMemberChange completes")

        StytchB2BClient.member.onMemberChange.sink { memberInfo in
            switch memberInfo {
            case .available:
                break
            case .unavailable:
                expectation.fulfill()
            }
        }.store(in: &subscriptions)

        Current.memberStorage.update(nil)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(StytchB2BClient.member.getSync())
    }
}
