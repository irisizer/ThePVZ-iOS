import SceneKit
import UIKit

enum MenuScene {
    static func makeScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = Palette.bgDeep
        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.position = SCNVector3(0, 1.6, 6.0)
        scene.rootNode.addChildNode(cam)
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = .omni
        light.light?.color = Palette.sodium
        light.position = SCNVector3(0, 4, 4)
        scene.rootNode.addChildNode(light)
        let floor = SCNNode(geometry: SCNPlane(width: 30, height: 30))
        floor.geometry?.firstMaterial?.diffuse.contents = Palette.bgPurple
        floor.eulerAngles = SCNVector3(-Float.pi / 2.0, 0, 0)
        floor.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(floor)
        let sign = NeonSign.makeNode(text: GameConfig.brandSignText)
        sign.position = SCNVector3(0, 2.4, -2.0)
        scene.rootNode.addChildNode(sign)
        let box = SCNNode(geometry: SCNBox(width: 1.2, height: 0.8, length: 0.8, chamferRadius: 0.05))
        box.geometry?.firstMaterial?.diffuse.contents = Palette.brand
        box.position = SCNVector3(0, 0.4, 0.5)
        scene.rootNode.addChildNode(box)
        return scene
    }
}
