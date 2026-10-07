import Foundation

public enum Synth {
    public static func makeToneWAV(frequency: Double, duration: Double, sampleRate: Int = 22050) -> Data? {
        if frequency <= 0.0 {
            return nil
        }
        if duration <= 0.0 {
            return nil
        }
        let sr: Int = max(8000, sampleRate)
        let count: Int = Int(duration * Double(sr))
        if count <= 0 || count > 22050 * 5 {
            return nil
        }
        var pcm = [Int16](repeating: 0, count: count)
        let twoPi: Double = 6.283185307179586
        for i in 0..<count {
            let t: Double = Double(i) / Double(sr)
            let env: Double = envelope(index: i, total: count)
            let s: Double = sin(twoPi * frequency * t) * env * 0.5
            let v: Double = max(-1.0, min(1.0, s))
            pcm[i] = Int16(v * 32767.0)
        }
        return wavFromPCM(samples: pcm, sampleRate: sr)
    }

    public static func makeNoiseWAV(duration: Double, sampleRate: Int = 22050, seed: UInt64 = 12345) -> Data? {
        if duration <= 0.0 {
            return nil
        }
        let sr: Int = max(8000, sampleRate)
        let count: Int = Int(duration * Double(sr))
        if count <= 0 || count > 22050 * 5 {
            return nil
        }
        var rng = SeededRNG(seed: seed)
        var pcm = [Int16](repeating: 0, count: count)
        for i in 0..<count {
            let env: Double = envelope(index: i, total: count)
            let r: Double = rng.nextDouble() * 2.0 - 1.0
            let s: Double = r * env * 0.35
            pcm[i] = Int16(max(-1.0, min(1.0, s)) * 32767.0)
        }
        return wavFromPCM(samples: pcm, sampleRate: sr)
    }

    private static func envelope(index: Int, total: Int) -> Double {
        if total <= 1 {
            return 1.0
        }
        let f: Double = Double(index) / Double(total)
        if f < 0.05 {
            return f / 0.05
        }
        if f > 0.85 {
            return (1.0 - f) / 0.15
        }
        return 1.0
    }

    private static func wavFromPCM(samples: [Int16], sampleRate: Int) -> Data? {
        let dataSize: UInt32 = UInt32(samples.count * 2)
        var out = Data()
        out.append(contentsOf: [0x52, 0x49, 0x46, 0x46])
        let chunk: UInt32 = 36 + dataSize
        appendU32(value: chunk, to: &out)
        out.append(contentsOf: [0x57, 0x41, 0x56, 0x45])
        out.append(contentsOf: [0x66, 0x6D, 0x74, 0x20])
        appendU32(value: 16, to: &out)
        appendU16(value: 1, to: &out)
        appendU16(value: 1, to: &out)
        appendU32(value: UInt32(sampleRate), to: &out)
        let byteRate: UInt32 = UInt32(sampleRate * 2)
        appendU32(value: byteRate, to: &out)
        appendU16(value: 2, to: &out)
        appendU16(value: 16, to: &out)
        out.append(contentsOf: [0x64, 0x61, 0x74, 0x61])
        appendU32(value: dataSize, to: &out)
        for s in samples {
            appendU16(value: UInt16(bitPattern: s), to: &out)
        }
        return out
    }

    private static func appendU32(value: UInt32, to data: inout Data) {
        let a: UInt8 = UInt8(value & 0xFF)
        let b: UInt8 = UInt8((value >> 8) & 0xFF)
        let c: UInt8 = UInt8((value >> 16) & 0xFF)
        let d: UInt8 = UInt8((value >> 24) & 0xFF)
        data.append(contentsOf: [a, b, c, d])
    }

    private static func appendU16(value: UInt16, to data: inout Data) {
        let a: UInt8 = UInt8(value & 0xFF)
        let b: UInt8 = UInt8((value >> 8) & 0xFF)
        data.append(contentsOf: [a, b])
    }
}
