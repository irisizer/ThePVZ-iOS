import Foundation
import AVFoundation

public final class AudioManager {
    public static let shared = AudioManager()
    private var players: [AVAudioPlayer] = []
    private let maxPool: Int = 6
    private var enabled: Bool = true

    private init() {}

    public func setEnabled(_ on: Bool) {
        enabled = on
        if on == false {
            stopAll()
        }
    }

    public func isEnabled() -> Bool {
        if Settings.shared.soundEnabled == false {
            return false
        }
        return enabled
    }

    public func play(_ name: SoundName) {
        if isEnabled() == false {
            return
        }
        if playFile(name) {
            return
        }
        playSynth(name)
    }

    public func stopAll() {
        for p in players {
            p.stop()
        }
        players.removeAll()
    }

    private func playFile(_ name: SoundName) -> Bool {
        let fname = SoundBank.fileName(for: name)
        if let res = Bundle.main.resourcePath {
            let fm = FileManager.default
            let rels: [String] = [fname, "Audio/" + fname, "Resources/Audio/" + fname, "Resources/" + fname]
            for rel in rels {
                let p = (res as NSString).appendingPathComponent(rel)
                if fm.fileExists(atPath: p) {
                    if playPath(path: p) {
                        return true
                    }
                }
            }
        }
        if let url = Bundle.main.url(forResource: (fname as NSString).deletingPathExtension, withExtension: "wav") {
            if playURL(url: url) {
                return true
            }
        }
        if let url = Bundle.main.url(forResource: (fname as NSString).deletingPathExtension, withExtension: "wav", subdirectory: "Audio") {
            if playURL(url: url) {
                return true
            }
        }
        return false
    }

    private func playPath(path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        return playURL(url: url)
    }

    private func playURL(url: URL) -> Bool {
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            push(player: p)
            p.play()
            return true
        } catch {
            Log.warn("audio file failed: \(url.lastPathComponent)")
            return false
        }
    }

    private func playSynth(_ name: SoundName) {
        let freq: Double = SoundBank.synthFrequency(for: name)
        let dur: Double = durationFor(name: name)
        var data: Data? = nil
        let seedVal: UInt64 = seedFor(name: name)
        if name == .jumpscare || name == .ambient || name == .fail {
            data = Synth.makeNoiseWAV(duration: dur, seed: seedVal)
        } else {
            data = Synth.makeToneWAV(frequency: freq, duration: dur)
        }
        guard let d = data else {
            return
        }
        do {
            let p = try AVAudioPlayer(data: d)
            p.prepareToPlay()
            push(player: p)
            p.play()
        } catch {
            Log.warn("synth play failed")
        }
    }

    private func durationFor(name: SoundName) -> Double {
        switch name {
        case .click:
            return 0.12
        case .scan:
            return 0.8
        case .success:
            return 0.4
        case .fail:
            return 0.7
        case .alarm:
            return 0.6
        case .ambient:
            return 1.5
        case .jumpscare:
            return 1.2
        case .gbr:
            return 0.9
        case .courier:
            return 0.5
        }
    }

    private func seedFor(name: SoundName) -> UInt64 {
        switch name {
        case .click:
            return 11
        case .scan:
            return 22
        case .success:
            return 33
        case .fail:
            return 44
        case .alarm:
            return 55
        case .ambient:
            return 66
        case .jumpscare:
            return 77
        case .gbr:
            return 88
        case .courier:
            return 99
        }
    }

    private func push(player: AVAudioPlayer) {
        players.append(player)
        while players.count > maxPool {
            let first = players.removeFirst()
            first.stop()
        }
    }
}
