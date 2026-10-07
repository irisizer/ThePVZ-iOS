import UIKit
import CoreHaptics

public enum HapticKind {
    case light
    case medium
    case heavy
    case success
    case warning
    case jumpscare
}

public final class Haptics {
    public static let shared = Haptics()
    private var engine: CHHapticEngine?
    private var didStart: Bool = false

    private init() {}

    public func prepare() {
        if Settings.shared.hapticsEnabled == false {
            return
        }
        if #available(iOS 13.0, *) {
            let cap = CHHapticEngine.capabilitiesForHardware()
            if cap.supportsHaptics == false {
                return
            }
            do {
                engine = try CHHapticEngine()
                try engine?.start()
                didStart = true
            } catch {
                engine = nil
                didStart = false
            }
        }
    }

    public func play(_ kind: HapticKind) {
        if Settings.shared.hapticsEnabled == false {
            return
        }
        if playCoreHaptics(kind) {
            return
        }
        playFallback(kind)
    }

    private func playCoreHaptics(_ kind: HapticKind) -> Bool {
        if #available(iOS 13.0, *) {
            guard let eng = engine else {
                return false
            }
            if didStart == false {
                return false
            }
            let sharp: Float = sharpnessFor(kind: kind)
            let inten: Float = intensityFor(kind: kind)
            let ev = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharp),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: inten)
                ],
                relativeTime: 0
            )
            do {
                let pat = try CHHapticPattern(events: [ev], parameters: [])
                let player = try eng.makePlayer(with: pat)
                try player.start(atTime: 0)
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }

    private func playFallback(_ kind: HapticKind) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = styleFor(kind: kind)
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.prepare()
        gen.impactOccurred()
    }

    private func sharpnessFor(kind: HapticKind) -> Float {
        switch kind {
        case .light:
            return 0.3
        case .medium:
            return 0.5
        case .heavy:
            return 0.8
        case .success:
            return 0.4
        case .warning:
            return 0.7
        case .jumpscare:
            return 1.0
        }
    }

    private func intensityFor(kind: HapticKind) -> Float {
        switch kind {
        case .light:
            return 0.4
        case .medium:
            return 0.7
        case .heavy:
            return 1.0
        case .success:
            return 0.6
        case .warning:
            return 0.9
        case .jumpscare:
            return 1.0
        }
    }

    private func styleFor(kind: HapticKind) -> UIImpactFeedbackGenerator.FeedbackStyle {
        switch kind {
        case .light:
            return .light
        case .medium:
            return .medium
        case .heavy:
            return .heavy
        case .success:
            return .medium
        case .warning:
            return .heavy
        case .jumpscare:
            return .heavy
        }
    }
}
