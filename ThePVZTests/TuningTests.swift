import XCTest
@testable import ThePVZ

final class TuningTests: XCTestCase {
    func testNightsTotal() {
        XCTAssertEqual(Tuning.nightsTotal, 5)
    }

    func testClientsPerNight() {
        XCTAssertEqual(Tuning.clients(forNight: 1), 4)
        XCTAssertEqual(Tuning.clients(forNight: 5), 10)
        XCTAssertTrue(Tuning.clients(forNight: 0) > 0)
        XCTAssertTrue(Tuning.clients(forNight: 99) > 0)
    }

    func testDurationPositive() {
        for n in 1...5 {
            let d: Double = Tuning.duration(forNight: n)
            XCTAssertTrue(d >= 60.0)
        }
    }

    func testComplaintsLimit() {
        XCTAssertEqual(Tuning.complaintsLimit, 3)
    }

    func testGameConfigBrand() {
        XCTAssertEqual(GameConfig.brandSignText, "Shmaildberries")
        XCTAssertTrue(GameConfig.isNightValid(1))
        XCTAssertTrue(GameConfig.isNightValid(5))
        XCTAssertFalse(GameConfig.isNightValid(0))
        XCTAssertFalse(GameConfig.isNightValid(6))
    }
}
