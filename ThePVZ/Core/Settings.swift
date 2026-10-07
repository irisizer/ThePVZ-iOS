import Foundation

public final class Settings {
    public static let shared = Settings()
    private let defaults: UserDefaults = UserDefaults.standard

    private let kSound: String = "thepvz.sound"
    private let kHaptics: String = "thepvz.haptics"
    private let kQuality: String = "thepvz.quality"

    private init() {}

    public var soundEnabled: Bool {
        get {
            if defaults.object(forKey: kSound) == nil {
                return true
            }
            return defaults.bool(forKey: kSound)
        }
        set {
            defaults.set(newValue, forKey: kSound)
        }
    }

    public var hapticsEnabled: Bool {
        get {
            if defaults.object(forKey: kHaptics) == nil {
                return true
            }
            return defaults.bool(forKey: kHaptics)
        }
        set {
            defaults.set(newValue, forKey: kHaptics)
        }
    }

    public var quality: GameConfig.Quality {
        get {
            let v: Int = defaults.integer(forKey: kQuality)
            if v == 0 {
                return .high
            }
            return .low
        }
        set {
            defaults.set(newValue.rawValue + 1, forKey: kQuality)
        }
    }

    public var isLowQuality: Bool {
        return quality == .low
    }

    public func reset() {
        soundEnabled = true
        hapticsEnabled = true
        quality = .high
    }
}
