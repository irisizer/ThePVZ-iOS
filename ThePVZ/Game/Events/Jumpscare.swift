import UIKit
import SceneKit

final class Jumpscare {
    private var overlay: UIView?

    func play(on hostView: UIView, completion: (() -> Void)?) {
        AudioManager.shared.play(.jumpscare)
        Haptics.shared.play(.jumpscare)
        let v = UIView(frame: hostView.bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = UIColor.black
        let face = UIView()
        face.backgroundColor = Palette.alarmRed
        face.layer.cornerRadius = 60.0
        face.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(face)
        let eyeL = UIView()
        eyeL.backgroundColor = UIColor.black
        eyeL.layer.cornerRadius = 18.0
        eyeL.translatesAutoresizingMaskIntoConstraints = false
        let eyeR = UIView()
        eyeR.backgroundColor = UIColor.black
        eyeR.layer.cornerRadius = 18.0
        eyeR.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(eyeL)
        v.addSubview(eyeR)
        let mouth = UIView()
        mouth.backgroundColor = UIColor.black
        mouth.layer.cornerRadius = 20.0
        mouth.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(mouth)
        hostView.addSubview(v)
        NSLayoutConstraint.activate([
            face.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            face.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            face.widthAnchor.constraint(equalToConstant: 220.0),
            face.heightAnchor.constraint(equalToConstant: 260.0),
            eyeL.topAnchor.constraint(equalTo: face.topAnchor, constant: 50.0),
            eyeL.leftAnchor.constraint(equalTo: face.leftAnchor, constant: 35.0),
            eyeL.widthAnchor.constraint(equalToConstant: 45.0),
            eyeL.heightAnchor.constraint(equalToConstant: 45.0),
            eyeR.topAnchor.constraint(equalTo: face.topAnchor, constant: 50.0),
            eyeR.rightAnchor.constraint(equalTo: face.rightAnchor, constant: -35.0),
            eyeR.widthAnchor.constraint(equalToConstant: 45.0),
            eyeR.heightAnchor.constraint(equalToConstant: 45.0),
            mouth.bottomAnchor.constraint(equalTo: face.bottomAnchor, constant: -40.0),
            mouth.centerXAnchor.constraint(equalTo: face.centerXAnchor),
            mouth.widthAnchor.constraint(equalToConstant: 90.0),
            mouth.heightAnchor.constraint(equalToConstant: 70.0)
        ])
        overlay = v
        v.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: 0.25, animations: {
            v.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                v.removeFromSuperview()
                if let cb = completion {
                    cb()
                }
            }
        })
    }
}
