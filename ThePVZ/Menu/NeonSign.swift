import SceneKit
import UIKit

enum NeonSign {
    static func makeNode(text: String) -> SCNNode {
        let parent = SCNNode()
        let txt = SCNText(string: text, extrusionDepth: 0.08)
        txt.font = UIFont.boldSystemFont(ofSize: 1.0)
        txt.firstMaterial?.diffuse.contents = Palette.neonPink
        txt.firstMaterial?.emission.contents = Palette.neonPink
        txt.alignmentMode = "center"
        let node = SCNNode(geometry: txt)
        let s: Float = 0.55
        node.scale = SCNVector3(s, s, s)
        node.position = SCNVector3(-2.6, 0, 0)
        parent.addChildNode(node)
        let glow = SCNNode(geometry: SCNPlane(width: 6.5, height: 1.4))
        glow.geometry?.firstMaterial?.diffuse.contents = Palette.neonSoft.withAlphaComponent(0.12)
        glow.geometry?.firstMaterial?.isDoubleSided = true
        glow.position = SCNVector3(0, 0.4, -0.15)
        parent.addChildNode(glow)
        return parent
    }
}
