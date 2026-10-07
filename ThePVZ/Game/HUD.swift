import UIKit

protocol HUDDelegate: AnyObject {
    func hudDidTapIssue()
    func hudDidTapReject()
    func hudDidTapGBR()
    func hudDidTapScan()
    func hudDidTapCloseShift()
    func hudDidTapPause()
}

final class HUD: UIView {
    weak var delegate: HUDDelegate?

    private var complaintsLabel: UILabel?
    private var timerLabel: UILabel?
    private var gbrLabel: UILabel?
    private var waybillLabel: UILabel?
    private var qrView: UIImageView?
    private var hintLabel: UILabel?

    private var issueButton: UIButton?
    private var rejectButton: UIButton?
    private var gbrButton: UIButton?
    private var scanButton: UIButton?
    private var closeButton: UIButton?
    private var pauseButton: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.clear
        let cLabel = makeSmall(text: "\(Strings.hudComplaints): 0/\(Tuning.complaintsLimit)")
        let tLabel = makeSmall(text: "0:00")
        let gLabel = makeSmall(text: "")
        gLabel.textColor = Palette.alarmRed
        complaintsLabel = cLabel
        timerLabel = tLabel
        gbrLabel = gLabel
        let wLabel = UILabel()
        wLabel.textColor = Palette.text
        wLabel.font = Fonts.make(role: .caption, size: 12.0)
        wLabel.text = Strings.hudWaybill
        wLabel.textAlignment = .center
        wLabel.numberOfLines = 2
        waybillLabel = wLabel
        let qView = UIImageView()
        qView.contentMode = .scaleAspectFit
        qView.backgroundColor = UIColor.white
        qView.layer.cornerRadius = 6.0
        qView.clipsToBounds = true
        qrView = qView
        let hLabel = UILabel()
        hLabel.textColor = Palette.sodium
        hLabel.font = Fonts.make(role: .caption, size: 12.0)
        hLabel.textAlignment = .center
        hLabel.text = ""
        hintLabel = hLabel

        let iBtn = makeBtn(title: Strings.actIssue, color: Palette.ok)
        iBtn.addTarget(self, action: #selector(tapIssue), for: .touchUpInside)
        issueButton = iBtn
        let rBtn = makeBtn(title: Strings.actReject, color: Palette.sodium)
        rBtn.addTarget(self, action: #selector(tapReject), for: .touchUpInside)
        rejectButton = rBtn
        let gBtn = makeBtn(title: Strings.actGBR, color: Palette.alarmRed)
        gBtn.addTarget(self, action: #selector(tapGBR), for: .touchUpInside)
        gbrButton = gBtn
        let sBtn = makeBtn(title: Strings.actScan, color: Palette.neonPink)
        sBtn.addTarget(self, action: #selector(tapScan), for: .touchUpInside)
        scanButton = sBtn
        let clBtn = makeBtn(title: Strings.hudCloseShift, color: Palette.brand)
        clBtn.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        closeButton = clBtn
        let pBtn = makeBtn(title: "II", color: Palette.glass)
        pBtn.addTarget(self, action: #selector(tapPause), for: .touchUpInside)
        pauseButton = pBtn

        let top = UIStackView(arrangedSubviews: [cLabel, tLabel, gLabel, pBtn])
        top.axis = .horizontal
        top.spacing = 10.0
        top.distribution = .equalSpacing
        top.translatesAutoresizingMaskIntoConstraints = false
        addSubview(top)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Palette.glass
        card.layer.cornerRadius = 10.0
        card.layer.borderColor = Palette.neonPink.cgColor
        card.layer.borderWidth = 1.0
        addSubview(card)
        let cardCol = UIStackView(arrangedSubviews: [wLabel, qView, hLabel])
        cardCol.axis = .vertical
        cardCol.spacing = 6.0
        cardCol.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardCol)

        let actions = UIStackView(arrangedSubviews: [iBtn, rBtn, gBtn, sBtn])
        actions.axis = .horizontal
        actions.spacing = 8.0
        actions.distribution = .fillEqually
        actions.translatesAutoresizingMaskIntoConstraints = false
        addSubview(actions)
        clBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(clBtn)

        NSLayoutConstraint.activate([
            top.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6.0),
            top.leftAnchor.constraint(equalTo: leftAnchor, constant: 10.0),
            top.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0),
            card.topAnchor.constraint(equalTo: top.bottomAnchor, constant: 8.0),
            card.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0),
            card.widthAnchor.constraint(equalToConstant: 170.0),
            card.heightAnchor.constraint(equalToConstant: 210.0),
            cardCol.topAnchor.constraint(equalTo: card.topAnchor, constant: 8.0),
            cardCol.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 8.0),
            cardCol.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -8.0),
            cardCol.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8.0),
            qView.heightAnchor.constraint(equalToConstant: 110.0),
            actions.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10.0),
            actions.leftAnchor.constraint(equalTo: leftAnchor, constant: 10.0),
            actions.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0),
            actions.heightAnchor.constraint(equalToConstant: 48.0),
            clBtn.bottomAnchor.constraint(equalTo: actions.topAnchor, constant: -8.0),
            clBtn.centerXAnchor.constraint(equalTo: centerXAnchor),
            clBtn.widthAnchor.constraint(equalToConstant: 200.0),
            clBtn.heightAnchor.constraint(equalToConstant: 40.0)
        ])
    }

    private func makeSmall(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.textColor = Palette.text
        l.font = Fonts.make(role: .caption, size: 12.0)
        return l
    }

    private func makeBtn(title: String, color: UIColor) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(Palette.text, for: .normal)
        b.titleLabel?.font = Fonts.make(role: .button, size: 16.0)
        b.backgroundColor = color.withAlphaComponent(0.85)
        b.layer.cornerRadius = 10.0
        return b
    }

    func setComplaints(_ v: Int) {
        complaintsLabel?.text = "\(Strings.hudComplaints): \(v)/\(Tuning.complaintsLimit)"
    }

    func setTimer(sec: Double) {
        let s: Int = Int(sec)
        let m: Int = s / 60
        let r: Int = s % 60
        let txt: String = "\(m):\(r < 10 ? "0" : "")\(r)"
        timerLabel?.text = txt
    }

    func setGBR(_ visible: Bool) {
        if visible {
            gbrLabel?.text = Strings.hudGBR
        } else {
            gbrLabel?.text = ""
        }
    }

    func setWaybill(code: String, qr: UIImage?) {
        waybillLabel?.text = "\(Strings.hudWaybill)\n\(code)"
        qrView?.image = qr
    }

    func setHint(_ t: String) {
        hintLabel?.text = t
    }

    func setActionsEnabled(_ on: Bool) {
        issueButton?.isEnabled = on
        rejectButton?.isEnabled = on
        gbrButton?.isEnabled = on
        scanButton?.isEnabled = on
    }

    @objc private func tapIssue() {
        delegate?.hudDidTapIssue()
    }

    @objc private func tapReject() {
        delegate?.hudDidTapReject()
    }

    @objc private func tapGBR() {
        delegate?.hudDidTapGBR()
    }

    @objc private func tapScan() {
        delegate?.hudDidTapScan()
    }

    @objc private func tapClose() {
        delegate?.hudDidTapCloseShift()
    }

    @objc private func tapPause() {
        delegate?.hudDidTapPause()
    }
}
