import Foundation

public struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        var s: UInt64 = seed
        if s == 0 {
            s = 0x9E3779B97F4A7C15
        }
        state = s
    }

    public mutating func next() -> UInt64 {
        var x: UInt64 = state
        x ^= x >> 12
        x ^= x << 25
        x ^= x >> 27
        state = x
        let out: UInt64 = x &* 2685821657736338717
        return out
    }

    public mutating func nextInt(upper: Int) -> Int {
        if upper <= 0 {
            return 0
        }
        let v: UInt64 = next()
        let m: UInt64 = UInt64(upper)
        return Int(v % m)
    }

    public mutating func nextDouble() -> Double {
        let v: UInt64 = next()
        let maxD: Double = Double(UInt64.max)
        let d: Double = Double(v) / maxD
        return d
    }

    public mutating func nextBool(probability: Double) -> Bool {
        if probability <= 0.0 {
            return false
        }
        if probability >= 1.0 {
            return true
        }
        let d: Double = nextDouble()
        return d < probability
    }
}
