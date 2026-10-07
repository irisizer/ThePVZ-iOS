import UIKit

final class PauseView: UIView {
    var onResume: (() -> Void)?
    var onSettings: (() -> Void)?
    var onMenu: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        isHidden = true
        let card = UIView()
        card.backgroundColor = Palette.glass
        card.layer.cornerRadius = 14.0
        card.layer.borderColor = Palette.neonPink.cgColor
        card.layer.borderWidth = 1.0
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)

        let warn = UILabel()
        warn.text = Strings.pauseWarning
        warn.textColor = Palette.text.withAlphaComponent(0.6)
        warn.font = Fonts.make(role: .caption, size: 12.0)
        warn.textAlignment = .center
        warn.numberOfLines = 0

        let b1 = makeBtn(title: Strings.continueGame)
        b1.addTarget(self, action: #selector(didResume), for: .touchUpInside)
        let b2 = makeBtn(title: Strings.settings)
        b2.addTarget(self, action: #selector(didSettings), for: .touchUpInside)
        let b3 = makeBtn(title: Strings.toMenu)
        b3.addTarget(self, action: #selector(didMenu), for: .touchUpInside)

        let col = UIStackView(arrangedSubviews: [warn, b1, b2, b3])
        col.axis = .vertical
        col.spacing = 10.0
        col.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(col)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 300.0),
            col.topAnchor.constraint(equalTo: card.topAnchor, constant: 16.0),
            col.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 16.0),
            col.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -16.0),
            col.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16.0)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func makeBtn(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(Palette.text, for: .normal)
        b.titleLabel?.font = Fonts.make(role: .button, size: 18.0)
        b.backgroundColor = Palette.brand
        b.layer.cornerRadius = 10.0
        b.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        return b
    }

    @objc private func didResume() {
        if let cb = onResume {
            cb()
        } else {
            isHidden = true
        }
    }

    @objc private func didSettings() {
        if let cb = onSettings {
            cb()
        }
    }

    @objc private func didMenu() {
        if let cb = onMenu {
            cb()
        }
    }
}
