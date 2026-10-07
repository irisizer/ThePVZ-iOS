import Foundation

final class AmbientEvents {
    private var timer: Timer?
    private weak var world: World?

    func start(in world: World) {
        stop()
        self.world = world
        timer = Timer.scheduledTimer(withTimeInterval: Tuning.ambientPeriodSec, repeats: true) { [weak self] _ in
            self?.fire()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        world = nil
    }

    private func fire() {
        guard let w = world else {
            return
        }
        w.setFlicker(on: true)
        AudioManager.shared.play(.ambient)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            w.setFlicker(on: false)
            w.monitor.showPVZ()
        }
        w.monitor.showNoise()
    }
}
