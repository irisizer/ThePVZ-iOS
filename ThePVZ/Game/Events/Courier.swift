import SceneKit
import UIKit

final class Courier {
    private var node: SCNNode?

    func trigger(in scene: SCNScene, completion: (() -> Void)?) {
        AudioManager.shared.play(.courier)
        let app = Appearance.make(isAnomaly: false, seed: 777)
        let n = HumanFactory.makeHuman(appearance: app)
        n.position = SCNVector3(-3.5, 0, -2.0)
        scene.rootNode.addChildNode(n)
        node = n
        let box = SCNNode(geometry: SCNBox(width: 0.5, height: 0.35, length: 0.4, chamferRadius: 0.02))
        box.geometry?.firstMaterial?.diffuse.contents = Palette.brand
        box.position = SCNVector3(0, 1.1, 0.35)
        n.addChildNode(box)
        let target = SCNVector3(-1.5, 0, -1.0)
        let anim = HumanAnimator()
        anim.walk(node: n, to: target, duration: 4.0) {
            let back = SCNVector3(-3.5, 0, -2.0)
            anim.leave(node: n, to: back) {
                if let cb = completion {
                    cb()
                }
            }
        }
    }

    func cancel() {
        if let n = node {
            n.removeAllActions()
            n.removeFromParentNode()
        }
        node = nil
    }
}
