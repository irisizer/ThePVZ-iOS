import Foundation

public enum Tuning {
    public static let nightsTotal: Int = 5
    public static let nightDurationSec: [Double] = [150.0, 170.0, 190.0, 210.0, 240.0]
    public static let clientsPerNight: [Int] = [4, 6, 7, 9, 10]
    public static let complaintsLimit: Int = 3
    public static let anomalyChance: [Double] = [0.25, 0.30, 0.35, 0.40, 0.45]
    public static let clientWalkDuration: Double = 8.0
    public static let clientAtDeskDuration: Double = 25.0
    public static let gbrDelaySec: Double = 12.0
    public static let scanDurationSec: Double = 2.5
    public static let courierNight: Int = 2
    public static let ambientPeriodSec: Double = 18.0
    public static let lowQualityMaxTris: Int = 120000
    public static let highQualityMaxTris: Int = 250000

    public static func duration(forNight night: Int) -> Double {
        let idx: Int = max(0, min(night - 1, nightDurationSec.count - 1))
        return nightDurationSec[idx]
    }

    public static func clients(forNight night: Int) -> Int {
        let idx: Int = max(0, min(night - 1, clientsPerNight.count - 1))
        return clientsPerNight[idx]
    }

    public static func anomalyProbability(forNight night: Int) -> Double {
        let idx: Int = max(0, min(night - 1, anomalyChance.count - 1))
        return anomalyChance[idx]
    }
}
