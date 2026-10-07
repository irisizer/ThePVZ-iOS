import SceneKit
import UIKit

final class MonitorScreen {
    let node: SCNNode
    private let material: SCNMaterial

    init() {
        material = SCNMaterial()
        material.diffuse.contents = Assets.pvzScreenImage()
        material.emission.contents = UIColor.white.withAlphaComponent(0.15)
        let plane = SCNPlane(width: 1.1, height: 0.62)
        plane.firstMaterial = material
        node = SCNNode(geometry: plane)
        node.position = SCNVector3(0.7, 1.65, 1.05)
        node.eulerAngles = SCNVector3(0, -0.15, 0)
    }

    func showPVZ() {
        material.diffuse.contents = Assets.pvzScreenImage()
    }

    func showNoise() {
        material.diffuse.contents = Assets.fallbackPVZImage()
    }

    func showColor(_ color: UIColor) {
        material.diffuse.contents = color
    }

    func showImage(_ image: UIImage) {
        material.diffuse.contents = image
    }
}
