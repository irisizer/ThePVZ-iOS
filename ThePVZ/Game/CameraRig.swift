import SceneKit
import UIKit

final class CameraRig {
    let cameraNode: SCNNode
    private var basePos: SCNVector3
    private var time: Double = 0.0

    init() {
        cameraNode = SCNNode()
        let cam = SCNCamera()
        cam.fieldOfView = 60.0
        cameraNode.camera = cam
        basePos = SCNVector3(0, 1.6, 3.2)
        cameraNode.position = basePos
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
    }

    func placeForGame() {
        basePos = SCNVector3(0, 1.6, 3.2)
        cameraNode.position = basePos
    }

    func sway(time t: Double) {
        time = t
        let dx: Float = Float(sin(t * 0.6)) * 0.03
        let dy: Float = Float(cos(t * 0.45)) * 0.02
        var p = basePos
        p.x = p.x + dx
        p.y = p.y + dy
        cameraNode.position = p
    }

    func shake(intensity: Float) {
        var p = basePos
        p.x = p.x + intensity * 0.15
        p.y = p.y - intensity * 0.1
        cameraNode.position = p
    }
}
