import SceneKit
import UIKit

final class Beam {
    let node: SCNNode
    private let spot: SCNLight

    init() {
        node = SCNNode()
        spot = SCNLight()
        spot.type = .spot
        spot.color = UIColor.white
        spot.intensity = 800.0
        spot.spotInnerAngle = 20.0
        spot.spotOuterAngle = 45.0
        node.light = spot
        node.position = SCNVector3(0, 1.5, 3.0)
    }

    func setOn(_ on: Bool) {
        if on {
            spot.intensity = 800.0
        } else {
            spot.intensity = 0.0
        }
    }

    func point(to target: SCNVector3) {
        let look = SCNLookAtConstraint(target: targetNode(pos: target))
        look.isGimbalLockEnabled = true
        node.constraints = [look]
    }

    private func targetNode(pos: SCNVector3) -> SCNNode {
        let n = SCNNode()
        n.position = pos
        if let parent = node.parent {
            parent.addChildNode(n)
        }
        return n
    }
}
