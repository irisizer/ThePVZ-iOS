import SceneKit
import UIKit

enum HumanFactory {
    static func makeHuman(appearance: Appearance) -> SCNNode {
        let root = SCNNode()
        root.name = "human"
        let h: Float = appearance.height
        let bodyH: Float = h * 0.55
        let headR: Float = 0.14

        let legs = SCNNode(geometry: SCNBox(width: 0.34, height: 0.75, length: 0.22, chamferRadius: 0.02))
        legs.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        legs.position = SCNVector3(0, 0.375, 0)
        root.addChildNode(legs)

        let torso = SCNNode(geometry: SCNBox(width: 0.46, height: CGFloat(bodyH), length: 0.26, chamferRadius: 0.03))
        torso.geometry?.firstMaterial?.diffuse.contents = appearance.clothes
        torso.position = SCNVector3(0, 0.75 + bodyH / 2.0, 0)
        root.addChildNode(torso)

        let head = SCNNode(geometry: SCNSphere(radius: CGFloat(headR)))
        head.geometry?.firstMaterial?.diffuse.contents = appearance.skin
        head.position = SCNVector3(0, 0.75 + bodyH + headR + 0.05, 0)
        head.name = "head"
        root.addChildNode(head)

        let eyeGeo = SCNSphere(radius: 0.022)
        eyeGeo.firstMaterial?.diffuse.contents = UIColor.black
        let eL = SCNNode(geometry: eyeGeo)
        eL.position = SCNVector3(-0.055, 0.03, 0.12)
        head.addChildNode(eL)
        let eR = SCNNode(geometry: eyeGeo)
        eR.position = SCNVector3(0.055, 0.03, 0.12)
        head.addChildNode(eR)

        let armGeo = SCNCapsule(capRadius: 0.06, height: 0.55)
        armGeo.firstMaterial?.diffuse.contents = appearance.clothes
        let aL = SCNNode(geometry: armGeo)
        aL.position = SCNVector3(-0.30, 0.75 + bodyH - 0.2, 0)
        aL.name = "armL"
        root.addChildNode(aL)
        let aR = SCNNode(geometry: armGeo)
        aR.position = SCNVector3(0.30, 0.75 + bodyH - 0.2, 0)
        aR.name = "armR"
        root.addChildNode(aR)

        if appearance.isAnomaly {
            AnomalyFeatures.apply(to: root, seed: appearance.seed)
        }
        return root
    }
}
