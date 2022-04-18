@testable import StytchCore
import XCTest

final class StytchCoreTestCase: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        StytchClient.configure(
            publicToken: "xyz",
            hostUrl: try XCTUnwrap(URL(string: "https://myapp.com"))
        )
    }

    @available(iOS 13.0, *)
    func testMagicLinksEmailLoginOrCreate() async throws {
        let container = DataContainer(data: BasicResponse(requestId: "1234", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        Current.networkingClient = .init(
            dataTaskClient: .mock(returning: .success(data))
        )
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: EmailParameters = .init(
            email: .init(rawValue: "asdf@stytch.com"),
            loginMagicLinkUrl: baseUrl.appendingPathComponent("login"),
            signupMagicLinkUrl: baseUrl.appendingPathComponent("signup"),
            loginExpiration: .init(rawValue: 30),
            signupExpiration: .init(rawValue: 30)
        )

        let response = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
    }

    func testPath() {
        let path = Path(rawValue: "path")
        XCTAssertEqual(path.rawValue, "path")
        XCTAssertEqual(path.appendingPathComponent("").rawValue, "path")
        XCTAssertEqual(path.appendingPathComponent("new_path").rawValue, "path/new_path")
        XCTAssertEqual(
            path.appendingPathComponent("new_path").appendingPathComponent("other_path").rawValue,
            "path/new_path/other_path"
        )
    }

    func testUrl() {
        let url = URL(string: "https://stytch.com/path/component")
        XCTAssertEqual(url?.path, "/path/component")
        let path = Path(rawValue: "/other/path")
        XCTAssertEqual(url?.appendingPathComponent(path).path, "/path/component/other/path")
    }

    func testLossyArray() throws {
        struct Test: Decodable {
            let stringDigit: String
        }
        let decoder = JSONDecoder()
        do {
            let json = "[{\"stringDigit\":\"one\"},{\"stringDigit\":2},{\"stringDigit\":\"three\"}]"
            let testArray = try decoder.decode(LossyArray<Test>.self, from: Data(json.utf8))
            XCTAssertEqual(testArray.wrappedValue.count, 2)
            XCTAssertEqual(testArray.wrappedValue[0].stringDigit, "one")
            XCTAssertEqual(testArray.wrappedValue[1].stringDigit, "three")
        }
        do {
            let json = "[{\"stringDigit\":\"one\"},{\"stringDigit\":\"two\"},{\"stringDigit\":\"three\"}]"
            let testArray = try decoder.decode(LossyArray<Test>.self, from: Data(json.utf8))
            XCTAssertEqual(testArray.wrappedValue.count, 3)
            XCTAssertEqual(testArray.wrappedValue[0].stringDigit, "one")
            XCTAssertEqual(testArray.wrappedValue[1].stringDigit, "two")
            XCTAssertEqual(testArray.wrappedValue[2].stringDigit, "three")
        }
    }
}
