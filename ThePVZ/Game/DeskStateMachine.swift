import Foundation

public enum DeskState: Int {
    case idle = 0
    case clientArrived = 1
    case scanning = 2
    case decision = 3
    case gbrCalled = 4
    case leaving = 5
}

public enum DeskEvent {
    case clientArrive
    case scanStart
    case scanDone
    case issue
    case reject
    case callGBR
    case gbrArrived
    case clientLeave
}

public struct DeskStateMachine {
    public var state: DeskState = .idle

    public init() {}

    public init(state: DeskState) {
        self.state = state
    }

    @discardableResult
    public mutating func handle(_ event: DeskEvent) -> Bool {
        switch state {
        case .idle:
            if event == .clientArrive {
                state = .clientArrived
                return true
            }
            return false
        case .clientArrived:
            switch event {
            case .scanStart:
                state = .scanning
                return true
            case .issue:
                state = .leaving
                return true
            case .reject:
                state = .leaving
                return true
            case .callGBR:
                state = .gbrCalled
                return true
            default:
                return false
            }
        case .scanning:
            if event == .scanDone {
                state = .decision
                return true
            }
            return false
        case .decision:
            switch event {
            case .issue:
                state = .leaving
                return true
            case .reject:
                state = .leaving
                return true
            case .callGBR:
                state = .gbrCalled
                return true
            default:
                return false
            }
        case .gbrCalled:
            if event == .gbrArrived {
                state = .leaving
                return true
            }
            return false
        case .leaving:
            if event == .clientLeave {
                state = .idle
                return true
            }
            return false
        }
    }
}

extension DeskEvent: Equatable {
    public static func == (lhs: DeskEvent, rhs: DeskEvent) -> Bool {
        switch (lhs, rhs) {
        case (.clientArrive, .clientArrive):
            return true
        case (.scanStart, .scanStart):
            return true
        case (.scanDone, .scanDone):
            return true
        case (.issue, .issue):
            return true
        case (.reject, .reject):
            return true
        case (.callGBR, .callGBR):
            return true
        case (.gbrArrived, .gbrArrived):
            return true
        case (.clientLeave, .clientLeave):
            return true
        default:
            return false
        }
    }
}
