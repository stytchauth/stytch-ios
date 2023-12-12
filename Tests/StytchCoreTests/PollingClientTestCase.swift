import XCTest
@testable import StytchCore

final class PollingClientTestCase: BaseTestCase {
    func testDefault() {
        var timer: Timer?
        Current.timer = { timeInterval, _, task in
            let newTimer = Timer(fire: .distantFuture, interval: timeInterval, repeats: true) { _ in task() }
            timer = newTimer
            return newTimer
        }
        var fireCount = 0
        var error: Error?
        let pollingClient: PollingClient = .init(
            interval: 5,
            maxRetries: 5,
            queue: .main
        ) { _, onFailure in
            fireCount += 1
            if let theError = error {
                // Clear the error so the RetryClient doesn't continue to retry
                error = nil
                onFailure(theError)
            }
        }

        XCTAssertEqual(fireCount, 0)
        XCTAssertNil(timer)

        pollingClient.start()

        XCTAssertEqual(fireCount, 0)

        timer?.fire()

        XCTAssertEqual(fireCount, 1)

        timer?.fire()

        XCTAssertEqual(fireCount, 2)

        timer?.fire()
        timer?.fire()

        XCTAssertEqual(fireCount, 4)

        // Test default RetryClient, executing the task immediately
        Current.asyncAfter = { $2() }
        error = StytchSDKError.consumerSDKNotConfigured

        timer?.fire()

        XCTAssertEqual(fireCount, 6)
    }
}
