import SceneKit
import UIKit

final class World {
    let scene: SCNScene
    let cameraRig: CameraRig
    let beam: Beam
    let monitor: MonitorScreen
    let deskPos = SCNVector3(0, 0, 0.2)
    let doorPos = SCNVector3(0, 0, -3.4)

    private var flickerOn: Bool = false
    private var roomLight: SCNNode?

    init(quality: GameConfig.Quality) {
        scene = SCNScene()
        scene.background.contents = Palette.bgDeep
        cameraRig = CameraRig()
        cameraRig.placeForGame()
        scene.rootNode.addChildNode(cameraRig.cameraNode)
        beam = Beam()
        scene.rootNode.addChildNode(beam.node)
        let room = RoomBuilder.buildRoom()
        scene.rootNode.addChildNode(room)
        monitor = MonitorScreen()
        scene.rootNode.addChildNode(monitor.node)
        let alarm = RoomBuilder.buildAlarmButton()
        scene.rootNode.addChildNode(alarm)
        let amb = SCNNode()
        amb.light = SCNLight()
        amb.light?.type = .ambient
        amb.light?.color = Palette.bgPurple
        amb.light?.intensity = 250.0
        scene.rootNode.addChildNode(amb)
        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .omni
        key.light?.color = Palette.sodium
        key.light?.intensity = 500.0
        key.position = SCNVector3(0, 3.0, 0.5)
        scene.rootNode.addChildNode(key)
        roomLight = key
        if quality == .low {
            beam.setOn(false)
        } else {
            beam.setOn(true)
        }
    }

    func setFlicker(on: Bool) {
        flickerOn = on
    }

    func update(time: Double) {
        cameraRig.sway(time: time)
        if flickerOn {
            let v: Double = sin(time * 30.0)
            if v > 0.7 {
                roomLight?.light?.intensity = 120.0
            } else {
                roomLight?.light?.intensity = 500.0
            }
        } else {
            roomLight?.light?.intensity = 500.0
        }
    }
}
