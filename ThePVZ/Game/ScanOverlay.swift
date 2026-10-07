import UIKit

final class ScanOverlay: UIView {
    private var line: UIView?
    private var isAnimating: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.25)
        isHidden = true
        let l = UIView()
        l.backgroundColor = Palette.scanRed
        addSubview(l)
        line = l
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func start() {
        isHidden = false
        isAnimating = true
        line?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 3.0)
        UIView.animate(withDuration: Tuning.scanDurationSec, delay: 0, options: [.curveLinear], animations: { [weak self] in
            guard let s = self else {
                return
            }
            s.line?.frame = CGRect(x: 0, y: s.bounds.height - 3.0, width: s.bounds.width, height: 3.0)
        }, completion: { [weak self] _ in
            self?.isAnimating = false
        })
    }

    func stop() {
        isHidden = true
        line?.layer.removeAllAnimations()
        isAnimating = false
    }
}
