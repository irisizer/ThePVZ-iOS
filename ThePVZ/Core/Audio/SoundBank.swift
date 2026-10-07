import Foundation

public enum SoundName: String, CaseIterable {
    case click
    case scan
    case success
    case fail
    case alarm
    case ambient
    case jumpscare
    case gbr
    case courier
}

public enum SoundBank {
    public static func fileName(for name: SoundName) -> String {
        switch name {
        case .click:
            return "click.wav"
        case .scan:
            return "scan.wav"
        case .success:
            return "success.wav"
        case .fail:
            return "fail.wav"
        case .alarm:
            return "alarm.wav"
        case .ambient:
            return "ambient.wav"
        case .jumpscare:
            return "jumpscare.wav"
        case .gbr:
            return "gbr.wav"
        case .courier:
            return "courier.wav"
        }
    }

    public static func synthFrequency(for name: SoundName) -> Double {
        switch name {
        case .click:
            return 660.0
        case .scan:
            return 880.0
        case .success:
            return 520.0
        case .fail:
            return 180.0
        case .alarm:
            return 440.0
        case .ambient:
            return 110.0
        case .jumpscare:
            return 220.0
        case .gbr:
            return 330.0
        case .courier:
            return 590.0
        }
    }
}
