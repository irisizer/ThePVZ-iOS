import Foundation
import CoreGraphics
import ImageIO
import CoreText

func log(_ s: String) {
    print(s)
}

func makeIcon() -> Bool {
    let size: Int = 1024
    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: cs,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        log("warning: cannot create CGContext")
        return false
    }
    // Background gradient pink-purple
    let topR: CGFloat = 0.42
    let topG: CGFloat = 0.18
    let topB: CGFloat = 0.80
    let botR: CGFloat = 0.10
    let botG: CGFloat = 0.02
    let botB: CGFloat = 0.18
    let top = CGColor(red: topR, green: topG, blue: topB, alpha: 1.0)
    let bot = CGColor(red: botR, green: botG, blue: botB, alpha: 1.0)
    guard let grad = CGGradient(
        colorsSpace: cs,
        colors: [top, bot] as CFArray,
        locations: [0.0, 1.0]
    ) else {
        log("warning: cannot create gradient")
        return false
    }
    let w = CGFloat(size)
    let h = CGFloat(size)
    ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: h), options: [])
    // Neon box
    let box = CGRect(x: w * 0.22, y: h * 0.30, width: w * 0.56, height: h * 0.40)
    ctx.setStrokeColor(CGColor(red: 1.0, green: 0.31, blue: 0.82, alpha: 1.0))
    ctx.setLineWidth(14.0)
    ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 40.0, color: CGColor(red: 1.0, green: 0.31, blue: 0.82, alpha: 0.9))
    ctx.stroke(box, width: 14.0)
    ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 0, color: nil)
    // Heart (two circles + triangle)
    let cx = w * 0.5
    let cy = h * 0.52
    let r = w * 0.09
    ctx.setFillColor(CGColor(red: 1.0, green: 0.55, blue: 0.90, alpha: 1.0))
    ctx.fillEllipse(in: CGRect(x: cx - r - r * 0.45, y: cy - r * 0.4, width: r * 1.3, height: r * 1.3))
    ctx.fillEllipse(in: CGRect(x: cx + r * 0.15, y: cy - r * 0.4, width: r * 1.3, height: r * 1.3))
    let path = CGMutablePath()
    path.move(to: CGPoint(x: cx - r * 1.25, y: cy + r * 0.35))
    path.addLine(to: CGPoint(x: cx + r * 1.25, y: cy + r * 0.35))
    path.addLine(to: CGPoint(x: cx, y: cy - r * 1.25))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.fillPath()
    // Text PVZ
    let text = "PVZ" as CFString
    let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 150, nil)
    let attrs: [CFString: Any] = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: CGColor(red: 1.0, green: 0.89, blue: 0.96, alpha: 1.0)
    ]
    guard let attrStr = CFAttributedStringCreate(nil, text, attrs as CFDictionary) else {
        log("warning: cannot create attr string")
        return false
    }
    let line = CTLineCreateWithAttributedString(attrStr)
    ctx.textPosition = CGPoint(x: w * 0.5 - 130, y: h * 0.16)
    CTLineDraw(line, ctx)
    guard let img = ctx.makeImage() else {
        log("warning: cannot make image")
        return false
    }
    let fm = FileManager.default
    let cwd = fm.currentDirectoryPath
    let dir = (cwd as NSString).appendingPathComponent("ThePVZ/Assets.xcassets/AppIcon.appiconset")
    let outPath = (dir as NSString).appendingPathComponent("icon.png")
    guard let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outPath) as CFURL, "public.png" as CFString, 1, nil) else {
        log("warning: cannot create destination at \(outPath)")
        return false
    }
    CGImageDestinationAddImage(dest, img, nil)
    if CGImageDestinationFinalize(dest) == false {
        log("warning: finalize failed")
        return false
    }
    // Rewrite Contents.json with filename
    let jsonPath = (dir as NSString).appendingPathComponent("Contents.json")
    let json = """
{
  "images": [
    {"idiom": "iphone", "scale": "2x", "size": "20x20", "filename": "icon.png"},
    {"idiom": "iphone", "scale": "3x", "size": "20x20", "filename": "icon.png"},
    {"idiom": "iphone", "scale": "2x", "size": "29x29", "filename": "icon.png"},
    {"idiom": "iphone", "scale": "3x", "size": "29x29", "filename": "icon.png"},
    {"idiom": "iphone", "scale": "2x", "size": "40x40", "filename": "icon.png"},
    {"idiom": "iphone", "scale": "3x", "size": "40x40", "filename": "icon.png"},
    {"idiom": "iphone", "scale": "2x", "size": "60x60", "filename": "icon.png"},
    {"idiom": "iphone", "scale": "3x", "size": "60x60", "filename": "icon.png"},
    {"idiom": "ios-marketing", "scale": "1x", "size": "1024x1024", "filename": "icon.png"}
  ],
  "info": {"author": "xcode", "version": 1}
}
"""
    do {
        try json.write(toFile: jsonPath, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        log("warning: cannot write Contents.json: \\(error)")
        return false
    }
    log("icon written to \(outPath)")
    return true
}

let ok = makeIcon()
if ok == false {
    print("::warning::make_icon failed, continuing with safe Contents.json")
}
