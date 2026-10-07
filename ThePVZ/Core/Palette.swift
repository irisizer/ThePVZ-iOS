import UIKit

public enum Palette {
    public static let bgDeep: UIColor = UIColor(hex: 0x05000A)
    public static let bgPurple: UIColor = UIColor(hex: 0x1B0630)
    public static let brand: UIColor = UIColor(hex: 0x6B2FCB)
    public static let neonPink: UIColor = UIColor(hex: 0xFF4FD0)
    public static let neonSoft: UIColor = UIColor(hex: 0xFF9AE6)
    public static let neonCore: UIColor = UIColor(hex: 0xFFE3F6)
    public static let alarmRed: UIColor = UIColor(hex: 0xFF1E3C)
    public static let scanRed: UIColor = UIColor(hex: 0xFF2A2A)
    public static let ok: UIColor = UIColor(hex: 0x3DDC84)
    public static let sodium: UIColor = UIColor(hex: 0xFFAE5C)
    public static let text: UIColor = UIColor(hex: 0xFFE6F7)
    public static let glass: UIColor = UIColor(hex: 0x1A0B28, alpha: 0.72)
}

public extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r: CGFloat = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g: CGFloat = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b: CGFloat = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
