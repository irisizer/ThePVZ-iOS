import SceneKit
import UIKit

enum AnomalyFeatures {
    static func anomalyKinds() -> [String] {
        return ["long-arms", "extra-eyes", "pale-skin", "tilted-head", "dark-mouth"]
    }

    static func apply(to node: SCNNode, seed: Int) {
        let kind: Int = abs(seed) % 5
        if kind == 0 {
            applyLongArms(to: node)
        } else if kind == 1 {
            applyExtraEyes(to: node)
        } else if kind == 2 {
            applyPaleSkin(to: node)
        } else if kind == 3 {
            applyTiltedHead(to: node)
        } else {
            applyDarkMouth(to: node)
        }
        // subtle body-horror: always elongate slightly
        node.scale = SCNVector3(1.0, 1.06, 1.0)
    }

    static func describe(seed: Int) -> String {
        let kinds = anomalyKinds()
        let idx: Int = abs(seed) % kinds.count
        return kinds[idx]
    }

    private static func applyLongArms(to node: SCNNode) {
        if let l = node.childNode(withName: "armL", recursively: true) {
            l.scale = SCNVector3(0.8, 1.7, 0.8)
            l.position = SCNVector3(l.position.x, l.position.y - 0.25, l.position.z)
        }
        if let r = node.childNode(withName: "armR", recursively: true) {
            r.scale = SCNVector3(0.8, 1.7, 0.8)
            r.position = SCNVector3(r.position.x, r.position.y - 0.25, r.position.z)
        }
    }

    private static func applyExtraEyes(to node: SCNNode) {
        guard let head = node.childNode(withName: "head", recursively: true) else {
            return
        }
        for i in 0..<3 {
            let e = SCNNode(geometry: SCNSphere(radius: 0.018))
            e.geometry?.firstMaterial?.diffuse.contents = Palette.alarmRed
            e.geometry?.firstMaterial?.emission.contents = Palette.alarmRed
            let fx: Float = Float(i - 1) * 0.05
            e.position = SCNVector3(fx, 0.09, 0.11)
            head.addChildNode(e)
        }
    }

    private static func applyPaleSkin(to node: SCNNode) {
        guard let head = node.childNode(withName: "head", recursively: true) else {
            return
        }
        head.geometry?.firstMaterial?.diffuse.contents = UIColor(white: 0.88, alpha: 1.0)
        head.geometry?.firstMaterial?.emission.contents = UIColor(white: 0.1, alpha: 1.0)
    }

    private static func applyTiltedHead(to node: SCNNode) {
        guard let head = node.childNode(withName: "head", recursively: true) else {
            return
        }
        head.eulerAngles = SCNVector3(0, 0, 0.45)
        head.position = SCNVector3(0.05, head.position.y, head.position.z)
    }

    private static func applyDarkMouth(to node: SCNNode) {
        guard let head = node.childNode(withName: "head", recursively: true) else {
            return
        }
        let mouth = SCNNode(geometry: SCNBox(width: 0.09, height: 0.05, length: 0.01, chamferRadius: 0.005))
        mouth.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        mouth.position = SCNVector3(0, -0.06, 0.125)
        head.addChildNode(mouth)
    }
}
