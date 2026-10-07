import UIKit
import SceneKit

final class DebugPanel: UIView {
    private var label: UILabel?
    private weak var scnView: SCNView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        isHidden = true
        let l = UILabel()
        l.textColor = UIColor.green
        l.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        addSubview(l)
        label = l
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: topAnchor, constant: 4.0),
            l.leftAnchor.constraint(equalTo: leftAnchor, constant: 6.0),
            l.rightAnchor.constraint(equalTo: rightAnchor, constant: -6.0),
            l.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func attach(view: SCNView) {
        scnView = view
    }

    func refresh(fps: Double, extra: String) {
        var nodes: Int = 0
        if let v = scnView {
            nodes = v.scene?.rootNode.childNodes.count ?? 0
        }
        let f: Int = Int(fps)
        label?.text = "fps:\(f) nodes:\(nodes) \(extra)"
    }
}
