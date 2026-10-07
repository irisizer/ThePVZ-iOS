import XCTest
@testable import ThePVZ

final class SeededRNGTests: XCTestCase {
    func testDeterministic() {
        var a = SeededRNG(seed: 123)
        var b = SeededRNG(seed: 123)
        let x1: UInt64 = a.next()
        let y1: UInt64 = b.next()
        XCTAssertEqual(x1, y1)
        let x2: UInt64 = a.next()
        let y2: UInt64 = b.next()
        XCTAssertEqual(x2, y2)
    }

    func testNextIntBounds() {
        var rng = SeededRNG(seed: 7)
        for _ in 0..<50 {
            let v: Int = rng.nextInt(upper: 10)
            XCTAssertTrue(v >= 0 && v < 10)
        }
        let z: Int = rng.nextInt(upper: 0)
        XCTAssertEqual(z, 0)
    }

    func testNextDoubleRange() {
        var rng = SeededRNG(seed: 99)
        for _ in 0..<50 {
            let d: Double = rng.nextDouble()
            XCTAssertTrue(d >= 0.0 && d <= 1.0)
        }
    }

    func testNextBoolEdges() {
        var rng = SeededRNG(seed: 5)
        XCTAssertFalse(rng.nextBool(probability: 0.0))
        XCTAssertTrue(rng.nextBool(probability: 1.0))
    }
}
