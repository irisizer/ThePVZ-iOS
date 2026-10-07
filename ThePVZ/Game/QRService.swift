import UIKit
import CoreImage

public final class QRService {
    private let context: CIContext

    public init() {
        context = CIContext(options: nil)
    }

    public func makeQR(text: String, size: CGFloat) -> UIImage? {
        guard let data = text.data(using: .utf8) else {
            return nil
        }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let out = filter.outputImage else {
            return nil
        }
        let scale: CGFloat = max(1.0, size / out.extent.width)
        let scaled = out.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cg = context.createCGImage(scaled, from: scaled.extent) else {
            return nil
        }
        return UIImage(cgImage: cg)
    }

    public func randomCode(rng: inout SeededRNG) -> String {
        let a: Int = 1000 + rng.nextInt(upper: 9000)
        let b: Int = 1000 + rng.nextInt(upper: 9000)
        return "PVZ-\(a)-\(b)"
    }
}
