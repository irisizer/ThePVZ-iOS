import UIKit

final class SettingsPanel: UIView {
    var onClose: (() -> Void)?

    private var soundSwitch: UISwitch?
    private var hapticsSwitch: UISwitch?
    private var qualitySeg: UISegmentedControl?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Palette.glass
        layer.cornerRadius = 16.0
        layer.borderColor = Palette.neonPink.cgColor
        layer.borderWidth = 1.0
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = Strings.settingsTitle
        title.textColor = Palette.text
        title.font = Fonts.make(role: .title, size: 22.0)
        title.textAlignment = .center
        addSubview(title)

        let soundLabel = makeLabel(text: Strings.tabSound)
        let sSw = UISwitch()
        sSw.onTintColor = Palette.neonPink
        sSw.addTarget(self, action: #selector(soundChanged), for: .valueChanged)
        soundSwitch = sSw

        let hapLabel = makeLabel(text: "Вибрация")
        let hSw = UISwitch()
        hSw.onTintColor = Palette.neonPink
        hSw.addTarget(self, action: #selector(hapChanged), for: .valueChanged)
        hapticsSwitch = hSw

        let qLabel = makeLabel(text: Strings.tabGraphics)
        let qSeg = UISegmentedControl(items: ["Высокое", "Низкое"])
        qSeg.selectedSegmentTintColor = Palette.brand
        qSeg.addTarget(self, action: #selector(qChanged), for: .valueChanged)
        qualitySeg = qSeg

        let backB = UIButton(type: .system)
        backB.setTitle(Strings.back, for: .normal)
        backB.setTitleColor(Palette.text, for: .normal)
        backB.titleLabel?.font = Fonts.make(role: .button, size: 18.0)
        backB.addTarget(self, action: #selector(didBack), for: .touchUpInside)

        let resetB = UIButton(type: .system)
        resetB.setTitle(Strings.reset, for: .normal)
        resetB.setTitleColor(Palette.text.withAlphaComponent(0.7), for: .normal)
        resetB.titleLabel?.font = Fonts.make(role: .body, size: 16.0)
        resetB.addTarget(self, action: #selector(didReset), for: .touchUpInside)

        let r1 = UIStackView(arrangedSubviews: [soundLabel, sSw])
        r1.axis = .horizontal
        r1.distribution = .equalSpacing
        let r2 = UIStackView(arrangedSubviews: [hapLabel, hSw])
        r2.axis = .horizontal
        r2.distribution = .equalSpacing
        let col = UIStackView(arrangedSubviews: [title, r1, r2, qLabel, qSeg, backB, resetB])
        col.translatesAutoresizingMaskIntoConstraints = false
        col.axis = .vertical
        col.spacing = 12.0
        addSubview(col)
        NSLayoutConstraint.activate([
            col.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
            col.leftAnchor.constraint(equalTo: leftAnchor, constant: 16.0),
            col.rightAnchor.constraint(equalTo: rightAnchor, constant: -16.0)
        ])
        refresh()
    }

    private func makeLabel(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.textColor = Palette.text
        l.font = Fonts.make(role: .body, size: 16.0)
        return l
    }

    func refresh() {
        soundSwitch?.isOn = Settings.shared.soundEnabled
        hapticsSwitch?.isOn = Settings.shared.hapticsEnabled
        if Settings.shared.isLowQuality {
            qualitySeg?.selectedSegmentIndex = 1
        } else {
            qualitySeg?.selectedSegmentIndex = 0
        }
    }

    @objc private func soundChanged() {
        guard let sw = soundSwitch else {
            return
        }
        Settings.shared.soundEnabled = sw.isOn
        AudioManager.shared.setEnabled(sw.isOn)
    }

    @objc private func hapChanged() {
        guard let sw = hapticsSwitch else {
            return
        }
        Settings.shared.hapticsEnabled = sw.isOn
    }

    @objc private func qChanged() {
        guard let q = qualitySeg else {
            return
        }
        if q.selectedSegmentIndex == 1 {
            Settings.shared.quality = .low
        } else {
            Settings.shared.quality = .high
        }
    }

    @objc private func didBack() {
        if let cb = onClose {
            cb()
        } else {
            isHidden = true
        }
    }

    @objc private func didReset() {
        Settings.shared.reset()
        AudioManager.shared.setEnabled(true)
        refresh()
    }
}
