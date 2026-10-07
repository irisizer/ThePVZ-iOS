import UIKit
import SceneKit

final class MenuViewController: UIViewController {
    private var sceneView: SCNView?
    private var playButton: UIButton?
    private var settingsButton: UIButton?
    private var exitButton: UIButton?
    private var creditButton: UIButton?
    private var titleLabel: UILabel?
    private var settingsPanel: SettingsPanel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bgDeep
        setupScene()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupScene() {
        let sv = SCNView(frame: view.bounds)
        sv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sv.backgroundColor = Palette.bgDeep
        sv.scene = MenuScene.makeScene()
        sv.allowsCameraControl = false
        view.addSubview(sv)
        sceneView = sv
    }

    private func setupUI() {
        let tLabel = UILabel()
        tLabel.translatesAutoresizingMaskIntoConstraints = false
        tLabel.text = GameConfig.brandSignText
        tLabel.textColor = Palette.neonPink
        tLabel.font = Fonts.make(role: .wordmark, size: 34.0)
        tLabel.textAlignment = .center
        tLabel.shadowColor = Palette.neonPink
        tLabel.shadowOffset = CGSize(width: 0, height: 0)
        view.addSubview(tLabel)
        titleLabel = tLabel

        let pBtn = makeButton(title: Strings.play)
        pBtn.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        playButton = pBtn
        let sBtn = makeButton(title: Strings.settings)
        sBtn.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
        settingsButton = sBtn
        let eBtn = makeButton(title: Strings.exitConfirm)
        eBtn.addTarget(self, action: #selector(didTapExit), for: .touchUpInside)
        exitButton = eBtn

        let cBtn = UIButton(type: .system)
        cBtn.translatesAutoresizingMaskIntoConstraints = false
        cBtn.setTitle(Strings.credit, for: .normal)
        cBtn.setTitleColor(Palette.text.withAlphaComponent(0.6), for: .normal)
        cBtn.titleLabel?.font = Fonts.make(role: .caption, size: 12.0)
        cBtn.addTarget(self, action: #selector(didTapCredit), for: .touchUpInside)
        view.addSubview(cBtn)
        creditButton = cBtn

        let stack = UIStackView(arrangedSubviews: [pBtn, sBtn, eBtn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14.0
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            tLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24.0),
            tLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20.0),
            stack.widthAnchor.constraint(equalToConstant: 260.0),
            cBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12.0),
            cBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        let panel = SettingsPanel()
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.isHidden = true
        panel.onClose = { [weak self] in
            self?.settingsPanel?.isHidden = true
        }
        view.addSubview(panel)
        settingsPanel = panel
        NSLayoutConstraint.activate([
            panel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            panel.widthAnchor.constraint(equalToConstant: 320.0),
            panel.heightAnchor.constraint(equalToConstant: 300.0)
        ])
    }

    private func makeButton(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(title, for: .normal)
        b.setTitleColor(Palette.text, for: .normal)
        b.titleLabel?.font = Fonts.make(role: .button, size: 22.0)
        b.backgroundColor = Palette.glass
        b.layer.cornerRadius = 12.0
        b.layer.borderColor = Palette.neonPink.cgColor
        b.layer.borderWidth = 1.5
        b.heightAnchor.constraint(equalToConstant: 52.0).isActive = true
        return b
    }

    @objc private func didTapPlay() {
        AudioManager.shared.play(.click)
        Haptics.shared.play(.light)
        AppFlow.showLoading(in: view.window, night: GameConfig.defaultNight)
    }

    @objc private func didTapSettings() {
        AudioManager.shared.play(.click)
        settingsPanel?.isHidden = false
        settingsPanel?.refresh()
    }

    @objc private func didTapExit() {
        AudioManager.shared.play(.click)
        let alert = UIAlertController(title: Strings.exitTitle, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.stay, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Strings.exitConfirm, style: .destructive, handler: { _ in
            exit(0)
        }))
        present(alert, animated: true, completion: nil)
    }

    @objc private func didTapCredit() {
        AppFlow.openTelegram(from: self)
    }
}
