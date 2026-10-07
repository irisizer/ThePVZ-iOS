import SceneKit
import UIKit

final class Swat {
    private var nodes: [SCNNode] = []
    private var cancelled: Bool = false

    func dispatch(in scene: SCNScene, completion: (() -> Void)?) {
        cancelled = false
        AudioManager.shared.play(.gbr)
        nodes.removeAll()
        for i in 0..<2 {
            let app = Appearance(skin: UIColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 1.0), clothes: UIColor.black, height: 1.8, isAnomaly: false, seed: 900 + i)
            let n = HumanFactory.makeHuman(appearance: app)
            let fx: Float = Float(i) * 0.8 - 0.4
            n.position = SCNVector3(fx, 0, -3.4)
            scene.rootNode.addChildNode(n)
            nodes.append(n)
            let anim = HumanAnimator()
            let target = SCNVector3(fx, 0, 0.0)
            anim.walk(node: n, to: target, duration: 3.0) { [weak self] in
                guard let s = self else {
                    return
                }
                if s.cancelled {
                    return
                }
                if i == 1 {
                    if let cb = completion {
                        cb()
                    }
                    s.clearAfterDelay()
                }
            }
        }
    }

    private func clearAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let s = self else {
                return
            }
            if s.cancelled {
                return
            }
            for n in s.nodes {
                n.removeFromParentNode()
            }
            s.nodes.removeAll()
        }
    }

    func cancel() {
        cancelled = true
        for n in nodes {
            n.removeAllActions()
            n.removeFromParentNode()
        }
        nodes.removeAll()
    }
}
