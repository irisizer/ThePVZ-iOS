import XCTest
@testable import ThePVZ

final class GameClockTests: XCTestCase {
    func testTick() {
        let c = GameClock(duration: 100.0)
        XCTAssertFalse(c.isFinished())
        XCTAssertEqual(c.remaining(), 100.0, accuracy: 0.01)
        c.tick(dt: 10.0)
        XCTAssertEqual(c.remaining(), 90.0, accuracy: 0.01)
    }

    func testFinish() {
        let c = GameClock(duration: 10.0)
        c.tick(dt: 5.0)
        XCTAssertFalse(c.isFinished())
        c.tick(dt: 5.0)
        XCTAssertTrue(c.isFinished())
        XCTAssertEqual(c.remaining(), 0.0, accuracy: 0.01)
    }

    func testReset() {
        let c = GameClock(duration: 50.0)
        c.tick(dt: 50.0)
        XCTAssertTrue(c.isFinished())
        c.reset(duration: 20.0)
        XCTAssertFalse(c.isFinished())
        XCTAssertEqual(c.remaining(), 20.0, accuracy: 0.01)
    }

    func testBadDtIgnored() {
        let c = GameClock(duration: 100.0)
        c.tick(dt: -5.0)
        XCTAssertEqual(c.remaining(), 100.0, accuracy: 0.01)
        c.tick(dt: 100.0)
        XCTAssertEqual(c.remaining(), 100.0, accuracy: 0.01)
    }
}
