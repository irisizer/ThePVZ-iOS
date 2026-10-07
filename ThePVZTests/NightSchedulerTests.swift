import XCTest
@testable import ThePVZ

final class NightSchedulerTests: XCTestCase {
    func testPlanNight1() {
        let p: NightPlan = NightScheduler.plan(for: 1)
        XCTAssertEqual(p.night, 1)
        XCTAssertEqual(p.clientsTotal, 4)
        XCTAssertTrue(p.anomalyChance > 0.0)
        XCTAssertTrue(p.duration > 0.0)
    }

    func testPlanNight5() {
        let p: NightPlan = NightScheduler.plan(for: 5)
        XCTAssertEqual(p.night, 5)
        XCTAssertEqual(p.clientsTotal, 10)
    }

    func testPlanClamped() {
        let p0: NightPlan = NightScheduler.plan(for: 0)
        XCTAssertEqual(p0.night, 1)
        let p9: NightPlan = NightScheduler.plan(for: 99)
        XCTAssertEqual(p9.night, 5)
    }

    func testNextNight() {
        XCTAssertEqual(NightScheduler.nextNight(after: 1), 2)
        XCTAssertEqual(NightScheduler.nextNight(after: 4), 5)
        XCTAssertNil(NightScheduler.nextNight(after: 5))
    }

    func testIsAnomalyDeterministic() {
        var r1 = SeededRNG(seed: 1)
        var r2 = SeededRNG(seed: 1)
        let a1: Bool = NightScheduler.isAnomaly(rng: &r1, chance: 0.5)
        let a2: Bool = NightScheduler.isAnomaly(rng: &r2, chance: 0.5)
        XCTAssertEqual(a1, a2)
    }
}
