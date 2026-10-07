import SceneKit
import UIKit

enum RoomBuilder {
    static func buildRoom() -> SCNNode {
        let root = SCNNode()
        let floor = SCNNode(geometry: SCNPlane(width: 20, height: 20))
        floor.geometry?.firstMaterial?.diffuse.contents = Palette.bgPurple
        floor.eulerAngles = SCNVector3(-Float.pi / 2.0, 0, 0)
        floor.position = SCNVector3(0, 0, 0)
        root.addChildNode(floor)

        let back = SCNNode(geometry: SCNPlane(width: 12, height: 4))
        back.geometry?.firstMaterial?.diffuse.contents = Palette.bgDeep
        back.position = SCNVector3(0, 2, -4)
        root.addChildNode(back)

        let left = SCNNode(geometry: SCNPlane(width: 12, height: 4))
        left.geometry?.firstMaterial?.diffuse.contents = Palette.bgPurple
        left.eulerAngles = SCNVector3(0, Float.pi / 2.0, 0)
        left.position = SCNVector3(-5, 2, 0)
        root.addChildNode(left)

        let right = SCNNode(geometry: SCNPlane(width: 12, height: 4))
        right.geometry?.firstMaterial?.diffuse.contents = Palette.bgPurple
        right.eulerAngles = SCNVector3(0, -Float.pi / 2.0, 0)
        right.position = SCNVector3(5, 2, 0)
        root.addChildNode(right)

        let lamp = SCNNode()
        lamp.light = SCNLight()
        lamp.light?.type = .omni
        lamp.light?.color = Palette.sodium
        lamp.light?.intensity = 600.0
        lamp.position = SCNVector3(0, 3.2, 0)
        root.addChildNode(lamp)

        let desk = buildDesk()
        root.addChildNode(desk)

        let mon = buildMonitorStand()
        root.addChildNode(mon)
        return root
    }

    static func buildDesk() -> SCNNode {
        let desk = SCNNode(geometry: SCNBox(width: 2.4, height: 0.12, length: 0.9, chamferRadius: 0.02))
        desk.geometry?.firstMaterial?.diffuse.contents = Palette.brand
        desk.position = SCNVector3(0, 0.95, 1.2)
        return desk
    }

    static func buildMonitorStand() -> SCNNode {
        let stand = SCNNode(geometry: SCNBox(width: 0.1, height: 0.6, length: 0.1, chamferRadius: 0.01))
        stand.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        stand.position = SCNVector3(0.7, 1.25, 1.1)
        return stand
    }

    static func buildAlarmButton() -> SCNNode {
        let b = SCNNode(geometry: SCNCylinder(radius: 0.09, height: 0.06))
        b.geometry?.firstMaterial?.diffuse.contents = Palette.alarmRed
        b.geometry?.firstMaterial?.emission.contents = Palette.alarmRed
        b.position = SCNVector3(-0.8, 1.04, 1.2)
        return b
    }
}
