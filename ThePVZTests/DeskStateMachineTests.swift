import XCTest
@testable import ThePVZ

final class DeskStateMachineTests: XCTestCase {
    func testIdleToArrived() {
        var m = DeskStateMachine()
        XCTAssertEqual(m.state, .idle)
        XCTAssertTrue(m.handle(.clientArrive))
        XCTAssertEqual(m.state, .clientArrived)
    }

    func testIssueFlow() {
        var m = DeskStateMachine()
        XCTAssertFalse(m.handle(.issue))
        XCTAssertTrue(m.handle(.clientArrive))
        XCTAssertTrue(m.handle(.issue))
        XCTAssertEqual(m.state, .leaving)
        XCTAssertTrue(m.handle(.clientLeave))
        XCTAssertEqual(m.state, .idle)
    }

    func testScanFlow() {
        var m = DeskStateMachine()
        XCTAssertTrue(m.handle(.clientArrive))
        XCTAssertTrue(m.handle(.scanStart))
        XCTAssertEqual(m.state, .scanning)
        XCTAssertFalse(m.handle(.issue))
        XCTAssertTrue(m.handle(.scanDone))
        XCTAssertEqual(m.state, .decision)
        XCTAssertTrue(m.handle(.reject))
        XCTAssertEqual(m.state, .leaving)
    }

    func testGBRFlow() {
        var m = DeskStateMachine()
        XCTAssertTrue(m.handle(.clientArrive))
        XCTAssertTrue(m.handle(.callGBR))
        XCTAssertEqual(m.state, .gbrCalled)
        XCTAssertFalse(m.handle(.issue))
        XCTAssertTrue(m.handle(.gbrArrived))
        XCTAssertEqual(m.state, .leaving)
    }
}
