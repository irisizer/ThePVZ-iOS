import SceneKit
import UIKit

enum PropsBuilder {
    static func buildPVZProps() -> SCNNode {
        let root = SCNNode()
        root.name = "pvz_props"
        let shelves = buildShelfRow()
        root.addChildNode(shelves)
        let boxes = buildBoxPile()
        root.addChildNode(boxes)
        let fitting = buildFittingRoom()
        root.addChildNode(fitting)
        return root
    }

    static func buildShelfRow() -> SCNNode {
        let root = SCNNode()
        root.name = "shelves"
        for i in 0..<2 {
            let fx: Float = -4.2
            let fz: Float = Float(i) * 2.2 - 1.1
            let shelf = buildOneShelf()
            shelf.position = SCNVector3(fx, 0, fz)
            root.addChildNode(shelf)
        }
        return root
    }

    private static func buildOneShelf() -> SCNNode {
        let root = SCNNode()
        let frameMat = SCNMaterial()
        frameMat.diffuse.contents = UIColor.darkGray
        let xs: [Float] = [-0.9, 0.9]
        let zs: [Float] = [-0.4, 0.4]
        for sx in xs {
            for sz in zs {
                let post = SCNNode(geometry: SCNBox(width: 0.08, height: 2.2, length: 0.08, chamferRadius: 0.01))
                post.geometry?.firstMaterial = frameMat
                post.position = SCNVector3(sx, 1.1, sz)
                root.addChildNode(post)
            }
        }
        for level in 0..<3 {
            let fy: Float = 0.4 + Float(level) * 0.65
            let plank = SCNNode(geometry: SCNBox(width: 1.9, height: 0.06, length: 0.9, chamferRadius: 0.01))
            plank.geometry?.firstMaterial?.diffuse.contents = UIColor(hex: 0x2A2A35)
            plank.position = SCNVector3(0, fy, 0)
            root.addChildNode(plank)
            for b in 0..<3 {
                // WB-style purple boxes on shelves
                let bw: CGFloat = 0.42
                let box = SCNNode(geometry: SCNBox(width: bw, height: 0.34, length: 0.4, chamferRadius: 0.02))
                box.geometry?.firstMaterial?.diffuse.contents = Palette.brand
                let bx: Float = Float(b - 1) * 0.55
                box.position = SCNVector3(bx, fy + 0.22, 0)
                root.addChildNode(box)
                let tape = SCNNode(geometry: SCNBox(width: bw + 0.01, height: 0.06, length: 0.41, chamferRadius: 0.005))
                tape.geometry?.firstMaterial?.diffuse.contents = Palette.neonSoft
                tape.position = box.position
                root.addChildNode(tape)
            }
        }
        return root
    }

    static func buildBoxPile() -> SCNNode {
        let root = SCNNode()
        root.name = "boxes"
        let spots: [(Float, Float, Float)] = [
            (2.6, 0.2, -1.6),
            (3.1, 0.2, -1.2),
            (2.8, 0.62, -1.4),
            (2.5, 0.2, 1.8),
            (3.0, 0.2, 1.6)
        ]
        for s in spots {
            let box = SCNNode(geometry: SCNBox(width: 0.55, height: 0.4, length: 0.5, chamferRadius: 0.02))
            box.geometry?.firstMaterial?.diffuse.contents = Palette.brand
            box.position = SCNVector3(s.0, s.1, s.2)
            box.eulerAngles = SCNVector3(0, s.0, 0)
            root.addChildNode(box)
        }
        return root
    }

    static func buildFittingRoom() -> SCNNode {
        let root = SCNNode()
        root.name = "fitting"
        let bx: Float = 3.4
        let bz: Float = 0.2
        let wallMat = SCNMaterial()
        wallMat.diffuse.contents = Palette.bgPurple
        wallMat.isDoubleSided = true
        let back = SCNNode(geometry: SCNPlane(width: 1.6, height: 2.2))
        back.geometry?.firstMaterial = wallMat
        back.position = SCNVector3(bx, 1.1, bz - 0.8)
        root.addChildNode(back)
        let left = SCNNode(geometry: SCNPlane(width: 1.6, height: 2.2))
        left.geometry?.firstMaterial = wallMat
        left.eulerAngles = SCNVector3(0, Float.pi / 2.0, 0)
        left.position = SCNVector3(bx - 0.8, 1.1, bz)
        root.addChildNode(left)
        let curtain = SCNNode(geometry: SCNPlane(width: 1.6, height: 1.9))
        curtain.geometry?.firstMaterial?.diffuse.contents = Palette.neonPink.withAlphaComponent(0.55)
        curtain.geometry?.firstMaterial?.isDoubleSided = true
        curtain.position = SCNVector3(bx, 1.05, bz + 0.8)
        root.addChildNode(curtain)
        let bar = SCNNode(geometry: SCNCylinder(radius: 0.02, height: 1.6))
        bar.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        bar.eulerAngles = SCNVector3(0, 0, Float.pi / 2.0)
        bar.position = SCNVector3(bx, 2.0, bz + 0.8)
        root.addChildNode(bar)
        return root
    }
}
