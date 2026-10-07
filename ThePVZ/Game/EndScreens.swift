import UIKit

final class EndView: UIView {
    var onPrimary: (() -> Void)?
    var onMenu: (() -> Void)?

    private var titleLabel: UILabel?
    private var reasonLabel: UILabel?
    private var primaryButton: UIButton?
    private var menuButton: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.85)
        isHidden = true
        let card = UIView()
        card.backgroundColor = Palette.glass
        card.layer.cornerRadius = 14.0
        card.layer.borderColor = Palette.neonPink.cgColor
        card.layer.borderWidth = 1.0
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)
        let tLabel = UILabel()
        tLabel.textColor = Palette.neonPink
        tLabel.font = Fonts.make(role: .title, size: 24.0)
        tLabel.textAlignment = .center
        tLabel.numberOfLines = 0
        titleLabel = tLabel
        let rLabel = UILabel()
        rLabel.textColor = Palette.text
        rLabel.font = Fonts.make(role: .body, size: 16.0)
        rLabel.textAlignment = .center
        rLabel.numberOfLines = 0
        reasonLabel = rLabel
        let pBtn = UIButton(type: .system)
        pBtn.setTitleColor(Palette.text, for: .normal)
        pBtn.titleLabel?.font = Fonts.make(role: .button, size: 18.0)
        pBtn.backgroundColor = Palette.brand
        pBtn.layer.cornerRadius = 10.0
        pBtn.heightAnchor.constraint(equalToConstant: 46.0).isActive = true
        pBtn.addTarget(self, action: #selector(didPrimary), for: .touchUpInside)
        primaryButton = pBtn
        let mBtn = UIButton(type: .system)
        mBtn.setTitle(Strings.toMenu, for: .normal)
        mBtn.setTitleColor(Palette.text, for: .normal)
        mBtn.titleLabel?.font = Fonts.make(role: .button, size: 18.0)
        mBtn.backgroundColor = Palette.bgPurple
        mBtn.layer.cornerRadius = 10.0
        mBtn.heightAnchor.constraint(equalToConstant: 46.0).isActive = true
        mBtn.addTarget(self, action: #selector(didMenu), for: .touchUpInside)
        menuButton = mBtn
        let col = UIStackView(arrangedSubviews: [tLabel, rLabel, pBtn, mBtn])
        col.axis = .vertical
        col.spacing = 12.0
        col.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(col)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 320.0),
            col.topAnchor.constraint(equalTo: card.topAnchor, constant: 18.0),
            col.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 16.0),
            col.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -16.0),
            col.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18.0)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func showWin(night: Int, isFinal: Bool, onPrimary: @escaping () -> Void, onMenu: @escaping () -> Void) {
        self.onPrimary = onPrimary
        self.onMenu = onMenu
        if isFinal {
            titleLabel?.text = Strings.finalTitle
            reasonLabel?.text = ""
            primaryButton?.setTitle(Strings.toMenu, for: .normal)
        } else {
            titleLabel?.text = Strings.winTitle
            reasonLabel?.text = Strings.night(night)
            primaryButton?.setTitle(Strings.nextNight, for: .normal)
        }
        isHidden = false
    }

    func showFail(reason: String, onRetry: @escaping () -> Void, onMenu: @escaping () -> Void) {
        self.onPrimary = onRetry
        self.onMenu = onMenu
        titleLabel?.text = Strings.overTitle
        reasonLabel?.text = reason
        primaryButton?.setTitle(Strings.retryNight, for: .normal)
        isHidden = false
    }

    @objc private func didPrimary() {
        if let cb = onPrimary {
            cb()
        }
    }

    @objc private func didMenu() {
        if let cb = onMenu {
            cb()
        }
    }
}

enum EndScreens {
    static func makeView() -> EndView {
        return EndView()
    }
}
