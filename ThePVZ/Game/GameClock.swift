import Foundation

public final class GameClock {
    private var elapsedSec: Double = 0.0
    private var durationSec: Double = 150.0

    public init(duration: Double) {
        durationSec = max(10.0, duration)
    }

    public func reset(duration: Double) {
        durationSec = max(10.0, duration)
        elapsedSec = 0.0
    }

    @discardableResult
    public func tick(dt: Double) -> Bool {
        if dt > 0.0 && dt < 5.0 {
            elapsedSec = elapsedSec + dt
        }
        return isFinished()
    }

    public func isFinished() -> Bool {
        return elapsedSec >= durationSec
    }

    public func remaining() -> Double {
        let r: Double = durationSec - elapsedSec
        if r < 0.0 {
            return 0.0
        }
        return r
    }

    public func elapsed() -> Double {
        return elapsedSec
    }
}
