import SceneKit
import UIKit

final class InputRouter: NSObject {
    var onTap: ((CGPoint) -> Void)?

    func attach(to view: SCNView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        view.addGestureRecognizer(tap)
    }

    @objc private func didTap(_ g: UITapGestureRecognizer) {
        let p: CGPoint = g.location(in: g.view)
        if let cb = onTap {
            cb(p)
        }
    }
}
