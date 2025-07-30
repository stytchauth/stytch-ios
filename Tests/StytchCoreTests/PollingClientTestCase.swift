import XCTest
@testable import StytchCore

final class PollingClientTestCase: BaseTestCase {
    func testDefault() {
        let expectation = XCTestExpectation()
        let dispatchQueue = DispatchQueue(label: "test")
        let interval = 0.5
        var timer: DispatchSourceTimer?
        Current.timer = { interval, queue, task in
            let dst = DispatchSource.makeTimerSource(queue: queue)
            dst.schedule(deadline: .now() + interval, repeating: interval)
            dst.setEventHandler { task() }
            dst.resume()
            timer = dst
            return dst
        }
        var timestamps: [Date] = []
        var error: Error?
        let pollingClient: PollingClient = .init(
            interval: interval,
            maxRetries: 5,
            queue: dispatchQueue
        ) { _, onFailure in
            timestamps.append(Date.now)
            if let theError = error {
                // Clear the error so the RetryClient doesn't continue to retry
                error = nil
                onFailure(theError)
            }
        }

        XCTAssertEqual(timestamps.count, 0)
        XCTAssertNil(timer)

        pollingClient.start()
        // wait for it to fire a few times
        let secondsToRun = 3.0
        let expectedFires = secondsToRun / interval
        dispatchQueue.asyncAfter(deadline: .now() + secondsToRun, execute: { expectation.fulfill() })
        wait(for: [expectation], timeout: secondsToRun * 2)

        // did it fire the expected number of times?
        XCTAssertEqual(timestamps.count, Int(expectedFires))

        // was each fire _roughly_ one second apart?
        XCTAssertIntervalsClose(to: interval, in: timestamps, tolerance: 0.1)
    }
}
