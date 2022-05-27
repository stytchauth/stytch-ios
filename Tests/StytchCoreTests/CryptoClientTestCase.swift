import XCTest
@testable import StytchCore

final class CryptoClientTestCase: BaseTestCase {
    func testSha256() {
        XCTAssertEqual(
            Current.cryptoClient.sha256("test_123").toHexString(),
            "079caa5cce889201054c2eaf61dac76c838d438970bbb71085636d7dc1aba609"
        )
        XCTAssertEqual(
            Current.cryptoClient.sha256("asdfpoiu").toHexString(),
            "dad9243b0264932503dc0306e6a0321a8d262ddb022d7e5d15a847ea44aa3959"
        )
        XCTAssertEqual(
            Current.cryptoClient.sha256("i am crypto client").toHexString(),
            "b0f950f0d37d205d5d091a1517fb5fed40be37fd94ee0309b2c884f8ec2c928c"
        )
    }
}
