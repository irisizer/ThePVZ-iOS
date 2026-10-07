import UIKit
import CoreGraphics

public enum Assets {
    public static func pvzScreenImage() -> UIImage {
        if let img = bundledImage(named: GameConfig.pvzTextureName) {
            return img
        }
        return fallbackPVZImage()
    }

    public static func bundledImage(named: String) -> UIImage? {
        let fm = FileManager.default
        if let res = Bundle.main.resourcePath {
            let p1 = (res as NSString).appendingPathComponent(named)
            if fm.fileExists(atPath: p1) {
                if let img = UIImage(contentsOfFile: p1) {
                    return img
                }
            }
            let p2 = (res as NSString).appendingPathComponent("Textures/" + named)
            if fm.fileExists(atPath: p2) {
                if let img = UIImage(contentsOfFile: p2) {
                    return img
                }
            }
        }
        return UIImage(named: named)
    }

    public static func image(name: String) -> UIImage? {
        return bundledImage(named: name)
    }

    public static func fallbackPVZImage() -> UIImage {
        let w: Int = 512
        let h: Int = 288
        UIGraphicsBeginImageContext(CGSize(width: w, height: h))
        guard let c = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        c.setFillColor(CGColor(red: 0.30, green: 0.10, blue: 0.55, alpha: 1.0))
        c.fill(CGRect(x: 0, y: 0, width: w, height: h))
        c.setFillColor(CGColor(red: 0.42, green: 0.18, blue: 0.80, alpha: 1.0))
        c.fill(CGRect(x: 20, y: 20, width: w - 40, height: 60))
        c.setFillColor(CGColor(red: 1.0, green: 0.31, blue: 0.82, alpha: 1.0))
        c.fill(CGRect(x: 20, y: 100, width: w - 40, height: 120))
        let out = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return out ?? UIImage()
    }
}
