import UIKit

public struct Appearance {
    public var skin: UIColor
    public var clothes: UIColor
    public var height: Float
    public var isAnomaly: Bool
    public var seed: Int

    public init(skin: UIColor, clothes: UIColor, height: Float, isAnomaly: Bool, seed: Int) {
        self.skin = skin
        self.clothes = clothes
        self.height = height
        self.isAnomaly = isAnomaly
        self.seed = seed
    }

    public static func make(isAnomaly: Bool, seed: Int) -> Appearance {
        let skins: [UIColor] = [
            UIColor(red: 0.95, green: 0.80, blue: 0.68, alpha: 1.0),
            UIColor(red: 0.85, green: 0.65, blue: 0.52, alpha: 1.0),
            UIColor(red: 0.70, green: 0.52, blue: 0.40, alpha: 1.0)
        ]
        let clothes: [UIColor] = [
            UIColor(hex: 0x2A4D69),
            UIColor(hex: 0x4B7447),
            UIColor(hex: 0x7A3B3B),
            UIColor(hex: 0x555555)
        ]
        let si: Int = abs(seed) % skins.count
        let ci: Int = abs(seed / 7) % clothes.count
        let h: Float = 1.65 + Float(abs(seed) % 30) / 100.0
        return Appearance(skin: skins[si], clothes: clothes[ci], height: h, isAnomaly: isAnomaly, seed: seed)
    }
}
