import Foundation

public struct NightPlan {
    public let night: Int
    public let clientsTotal: Int
    public let anomalyChance: Double
    public let duration: Double
}

public enum NightScheduler {
    public static func plan(for night: Int) -> NightPlan {
        let n: Int = max(1, min(night, Tuning.nightsTotal))
        let c: Int = Tuning.clients(forNight: n)
        let a: Double = Tuning.anomalyProbability(forNight: n)
        let d: Double = Tuning.duration(forNight: n)
        return NightPlan(night: n, clientsTotal: c, anomalyChance: a, duration: d)
    }

    public static func isAnomaly(rng: inout SeededRNG, chance: Double) -> Bool {
        return rng.nextBool(probability: chance)
    }

    public static func nextNight(after night: Int) -> Int? {
        let nx: Int = night + 1
        if nx > Tuning.nightsTotal {
            return nil
        }
        return nx
    }
}
