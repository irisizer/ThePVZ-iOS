import UIKit
import CoreText

public enum FontRole {
    case wordmark
    case button
    case title
    case body
    case caption
}

public enum Fonts {
    private static var didRegister: Bool = false

    public static func registerCustomFonts() {
        if didRegister {
            return
        }
        didRegister = true
        let fm = FileManager.default
        guard let res = Bundle.main.resourcePath else {
            return
        }
        let candidates: [String] = ["Fonts", "Resources/Fonts"]
        for rel in candidates {
            let fontsDir = (res as NSString).appendingPathComponent(rel)
            var isDir: ObjCBool = false
            let exists = fm.fileExists(atPath: fontsDir, isDirectory: &isDir)
            if exists == false || isDir.boolValue == false {
                continue
            }
            guard let files = try? fm.contentsOfDirectory(atPath: fontsDir) else {
                continue
            }
            for name in files {
                let lower = name.lowercased()
                let isFont: Bool = lower.hasSuffix(".otf") || lower.hasSuffix(".ttf")
                if isFont == false {
                    continue
                }
                let full = (fontsDir as NSString).appendingPathComponent(name)
                let url = URL(fileURLWithPath: full)
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }

    public static func make(role: FontRole, size: CGFloat) -> UIFont {
        registerCustomFonts()
        let s: CGFloat = sizeFor(role: role, requested: size)
        if let f = gotham(role: role, size: s) {
            return f
        }
        if let f = montserrat(role: role, size: s) {
            return f
        }
        if let f = avenir(role: role, size: s) {
            return f
        }
        return UIFont.systemFont(ofSize: s, weight: weightFor(role: role))
    }

    private static func sizeFor(role: FontRole, requested: CGFloat) -> CGFloat {
        if requested > 1.0 {
            return requested
        }
        switch role {
        case .wordmark:
            return 54.0
        case .button:
            return 22.0
        case .title:
            return 28.0
        case .body:
            return 16.0
        case .caption:
            return 12.0
        }
    }

    private static func weightFor(role: FontRole) -> UIFont.Weight {
        switch role {
        case .wordmark:
            return .bold
        case .button:
            return .semibold
        case .title:
            return .bold
        case .body:
            return .medium
        case .caption:
            return .medium
        }
    }

    private static func gotham(role: FontRole, size: CGFloat) -> UIFont? {
        let names: [String] = namesFor(role: role, family: "GothamPro")
        for n in names {
            if let f = UIFont(name: n, size: size) {
                return f
            }
        }
        return nil
    }

    private static func montserrat(role: FontRole, size: CGFloat) -> UIFont? {
        var names: [String] = namesFor(role: role, family: "Montserrat")
        names.append("Montserrat")
        names.append("Montserrat-Regular")
        names.append("Montserrat-Variable")
        for n in names {
            if let f = UIFont(name: n, size: size) {
                return f
            }
        }
        return nil
    }

    private static func avenir(role: FontRole, size: CGFloat) -> UIFont? {
        switch role {
        case .wordmark:
            return UIFont(name: "AvenirNext-Heavy", size: size)
        case .button:
            return UIFont(name: "AvenirNext-DemiBold", size: size)
        case .title:
            return UIFont(name: "AvenirNext-Heavy", size: size)
        case .body:
            return UIFont(name: "AvenirNext-Medium", size: size)
        case .caption:
            return UIFont(name: "AvenirNext-Medium", size: size)
        }
    }

    private static func namesFor(role: FontRole, family: String) -> [String] {
        switch role {
        case .wordmark:
            return [family + "-Bold", family + "Bold", family + "-Black"]
        case .button:
            return [family + "-SemiBold", family + "SemiBold", family + "-Bold"]
        case .title:
            return [family + "-Bold", family + "Bold"]
        case .body:
            return [family + "-Medium", family + "Medium", family + "-Regular"]
        case .caption:
            return [family + "-Medium", family + "Medium"]
        }
    }
}
