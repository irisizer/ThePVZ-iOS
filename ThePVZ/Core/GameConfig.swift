import Foundation

public enum GameConfig {
    public static let appName: String = "ThePVZ"
    public static let displayName: String = "The PVZ"
    public static let brandSignText: String = "Shmaildberries"
    public static let telegramURLString: String = "https://t.me/esyle"
    public static let pvzTextureName: String = "pvz_screen.png"
    public static let defaultNight: Int = 1

    public enum Quality: Int {
        case low = 0
        case high = 1
    }

    public static func isNightValid(_ night: Int) -> Bool {
        return night >= 1 && night <= Tuning.nightsTotal
    }
}
