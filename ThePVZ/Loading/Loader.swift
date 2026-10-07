import Foundation

final class Loader {
    func load(progress: @escaping (Double) -> Void, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            Fonts.registerCustomFonts()
            progress(0.2)
            _ = Assets.fallbackPVZImage()
            progress(0.5)
            Haptics.shared.prepare()
            progress(0.7)
            Thread.sleep(forTimeInterval: 0.3)
            progress(1.0)
            completion()
        }
    }
}
