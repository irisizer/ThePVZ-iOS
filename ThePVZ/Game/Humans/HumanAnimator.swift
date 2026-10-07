import SceneKit

final class HumanAnimator {
    func walk(node: SCNNode, to target: SCNVector3, duration: Double, completion: (() -> Void)?) {
        let d: TimeInterval = max(0.5, duration)
        node.removeAllActions()
        let move = SCNAction.move(to: target, duration: d)
        move.timingMode = .easeInEaseOut
        let bob = SCNAction.repeatForever(SCNAction.sequence([
            SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.25),
            SCNAction.moveBy(x: 0, y: -0.03, z: 0, duration: 0.25)
        ]))
        node.runAction(bob, forKey: "bob")
        node.runAction(move, forKey: "walk") {
            node.removeAction(forKey: "bob")
            if let cb = completion {
                cb()
            }
        }
    }

    func idle(node: SCNNode) {
        node.removeAction(forKey: "walk")
    }

    func attack(node: SCNNode, target: SCNVector3) {
        node.removeAllActions()
        let rush = SCNAction.move(to: target, duration: 0.6)
        rush.timingMode = .easeIn
        let grow = SCNAction.scale(to: 1.6, duration: 0.6)
        let grp = SCNAction.group([rush, grow])
        node.runAction(grp)
    }

    func leave(node: SCNNode, to target: SCNVector3, completion: (() -> Void)?) {
        let d: TimeInterval = 3.0
        node.removeAction(forKey: "bob")
        let move = SCNAction.move(to: target, duration: d)
        node.runAction(move) {
            node.removeFromParentNode()
            if let cb = completion {
                cb()
            }
        }
    }
}
