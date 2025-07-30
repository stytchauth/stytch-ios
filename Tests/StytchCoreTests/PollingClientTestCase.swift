import XCTest
@testable import StytchCore

final class PollingClientTestCase: BaseTestCase {
    func testDefault() {
        let expectation = XCTestExpectation()
        let dispatchQueue = DispatchQueue(label: "test")
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
            queue: dispatchQueue
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

        dispatchQueue.asyncAfter(deadline: .now() + 1, execute: { expectation.fulfill() })
        wait(for: [expectation], timeout: 10)

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
