import UIKit
import SceneKit

final class GameViewController: UIViewController, HUDDelegate {
    private let night: Int
    private var scnView: SCNView?
    private var world: World?
    private var hud: HUD?
    private var pauseView: PauseView?
    private var endView: EndView?
    private var scanOverlay: ScanOverlay?
    private var debugPanel: DebugPanel?
    private var settingsPanel: SettingsPanel?

    private var plan: NightPlan = NightScheduler.plan(for: 1)
    private var clock: GameClock = GameClock(duration: 150.0)
    private var desk = DeskStateMachine()
    private var rng = SeededRNG(seed: 42)
    private var qr = QRService()
    private var animator = HumanAnimator()
    private var swat = Swat()
    private var jumpscare = Jumpscare()
    private var ambient = AmbientEvents()
    private var courier = Courier()
    private var router = InputRouter()

    private var complaints: Int = 0
    private var servedCount: Int = 0
    private var clientIndex: Int = 0
    private var currentNode: SCNNode?
    private var currentIsAnomaly: Bool = false
    private var currentCode: String = ""
    private var currentSeed: Int = 0
    private var gbrPending: Bool = false
    private var isOver: Bool = false
    private var didCourier: Bool = false

    private var tickTimer: Timer?
    private var startTime: Date = Date()
    private var lastTick: Date = Date()
    private var scanRevealed: Bool = false

    init(night: Int) {
        let n: Int = max(1, min(night, Tuning.nightsTotal))
        self.night = n
        super.init(nibName: nil, bundle: nil)
        self.plan = NightScheduler.plan(for: n)
        self.clock = GameClock(duration: self.plan.duration)
        let s: UInt64 = UInt64(n * 1000 + 7)
        rng = SeededRNG(seed: s)
    }

    required init?(coder: NSCoder) {
        self.night = 1
        super.init(coder: coder)
        self.plan = NightScheduler.plan(for: 1)
        self.clock = GameClock(duration: self.plan.duration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bgDeep
        let q: GameConfig.Quality = Settings.shared.quality
        let w = World(quality: q)
        world = w
        let sv = SCNView(frame: view.bounds)
        sv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sv.scene = w.scene
        sv.backgroundColor = Palette.bgDeep
        if Settings.shared.isLowQuality {
            sv.preferredFramesPerSecond = 30
        } else {
            sv.preferredFramesPerSecond = 60
        }
        view.addSubview(sv)
        scnView = sv

        let h = HUD(frame: view.bounds)
        h.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        h.delegate = self
        view.addSubview(h)
        hud = h

        let sc = ScanOverlay(frame: CGRect(x: 0, y: 80, width: view.bounds.width, height: 220))
        sc.autoresizingMask = [.flexibleWidth]
        view.addSubview(sc)
        scanOverlay = sc

        let pv = PauseView(frame: view.bounds)
        pv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pv)
        pauseView = pv
        pv.onResume = { [weak self] in
            self?.resumeGame()
        }
        pv.onMenu = { [weak self] in
            guard let s = self else {
                return
            }
            AppFlow.showMenuFrom(s)
        }
        pv.onSettings = { [weak self] in
            self?.showSettings()
        }

        let ev = EndScreens.makeView()
        ev.frame = view.bounds
        ev.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(ev)
        endView = ev

        let dbg = DebugPanel(frame: CGRect(x: 8, y: 50, width: 260, height: 40))
        view.addSubview(dbg)
        dbg.attach(view: sv)
        debugPanel = dbg

        let sp = SettingsPanel()
        sp.translatesAutoresizingMaskIntoConstraints = false
        sp.isHidden = true
        sp.onClose = { [weak self] in
            self?.settingsPanel?.isHidden = true
        }
        view.addSubview(sp)
        settingsPanel = sp
        NSLayoutConstraint.activate([
            sp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sp.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sp.widthAnchor.constraint(equalToConstant: 320.0),
            sp.heightAnchor.constraint(equalToConstant: 300.0)
        ])

        router.onTap = { [weak self] pt in
            self?.handleTap(point: pt)
        }
        router.attach(to: sv)
        let triple = UITapGestureRecognizer(target: self, action: #selector(toggleDebug))
        triple.numberOfTapsRequired = 3
        view.addGestureRecognizer(triple)

        h.setComplaints(0)
        h.setGBR(false)
        h.setActionsEnabled(false)
        h.setHint("")
        startNight()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tickTimer?.invalidate()
        ambient.stop()
    }

    deinit {
        tickTimer?.invalidate()
    }

    private func startNight() {
        isOver = false
        complaints = 0
        servedCount = 0
        clientIndex = 0
        startTime = Date()
        lastTick = Date()
        guard let w = world else {
            return
        }
        w.monitor.showPVZ()
        ambient.start(in: w)
        tickTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.spawnNextClient()
        }
    }

    private func tick() {
        if isOver {
            return
        }
        if let pv = pauseView {
            if pv.isHidden == false {
                lastTick = Date()
                return
            }
        }
        let now = Date()
        let dt: Double = now.timeIntervalSince(lastTick)
        lastTick = now
        let capped: Double = min(0.5, max(0.0, dt))
        let finished: Bool = clock.tick(dt: capped)
        let total: Double = now.timeIntervalSince(startTime)
        if let w = world {
            w.update(time: total)
        }
        hud?.setTimer(sec: clock.remaining())
        debugPanel?.refresh(fps: 60.0, extra: "n\(night) c\(servedCount)")
        if night == Tuning.courierNight && didCourier == false && total > 30.0 {
            didCourier = true
            if let w = world {
                courier.trigger(in: w.scene, completion: nil)
            }
        }
        if finished {
            winNight()
        }
    }

    private func spawnNextClient() {
        if isOver {
            return
        }
        guard let w = world else {
            return
        }
        guard let h = hud else {
            return
        }
        if clientIndex >= plan.clientsTotal {
            h.setActionsEnabled(false)
            h.setHint("Все клиенты обслужены. Закройте смену.")
            return
        }
        let seed: Int = 1000 + night * 100 + clientIndex * 17
        currentSeed = seed
        var localRng = rng
        let anomaly: Bool = NightScheduler.isAnomaly(rng: &localRng, chance: plan.anomalyChance)
        rng = localRng
        currentIsAnomaly = anomaly
        currentCode = qr.randomCode(rng: &rng)
        scanRevealed = false
        let app = Appearance.make(isAnomaly: anomaly, seed: seed)
        let node = HumanFactory.makeHuman(appearance: app)
        node.position = w.doorPos
        w.scene.rootNode.addChildNode(node)
        currentNode = node
        desk = DeskStateMachine()
        let okArrive: Bool = desk.handle(.clientArrive)
        if okArrive == false {
            Log.warn("desk arrive rejected")
        }
        AudioManager.shared.play(.courier)
        w.beam.point(to: w.deskPos)
        let target = w.deskPos
        animator.walk(node: node, to: target, duration: Tuning.clientWalkDuration) { [weak self] in
            guard let s = self else {
                return
            }
            if s.isOver {
                return
            }
            guard let cur = s.currentNode else {
                return
            }
            if cur !== node {
                return
            }
            let img = s.qr.makeQR(text: s.currentCode, size: 110.0)
            s.hud?.setWaybill(code: s.currentCode, qr: img)
            s.hud?.setActionsEnabled(true)
            s.hud?.setHint("")
            s.world?.monitor.showPVZ()
        }
        h.setHint("Клиент идёт...")
        h.setActionsEnabled(false)
    }

    private func removeCurrent(toBack: Bool) {
        guard let node = currentNode else {
            return
        }
        _ = toBack
        currentNode = nil
        hud?.setActionsEnabled(false)
        guard let w = world else {
            return
        }
        let back = w.doorPos
        animator.leave(node: node, to: back) { [weak self] in
            guard let s = self else {
                return
            }
            var m = s.desk
            let _ = m.handle(.clientLeave)
            s.desk = m
            if s.isOver == false {
                s.clientIndex = s.clientIndex + 1
                s.spawnNextClient()
            }
        }
    }

    func hudDidTapIssue() {
        if isOver {
            return
        }
        if currentNode == nil {
            return
        }
        AudioManager.shared.play(.click)
        var m = desk
        let can: Bool = (m.state == .clientArrived) || (m.state == .decision)
        if can == false {
            return
        }
        let _ = m.handle(.issue)
        desk = m
        if currentIsAnomaly {
            failAnomaly()
            return
        }
        Haptics.shared.play(.success)
        AudioManager.shared.play(.success)
        servedCount = servedCount + 1
        removeCurrent(toBack: true)
        checkAutoHint()
    }

    func hudDidTapReject() {
        if isOver {
            return
        }
        if currentNode == nil {
            return
        }
        AudioManager.shared.play(.click)
        var m = desk
        let can: Bool = (m.state == .clientArrived) || (m.state == .decision)
        if can == false {
            return
        }
        let _ = m.handle(.reject)
        desk = m
        if currentIsAnomaly {
            Haptics.shared.play(.success)
            AudioManager.shared.play(.success)
            servedCount = servedCount + 1
            hud?.setHint("Аномалия отогнана.")
        } else {
            addComplaint()
            servedCount = servedCount + 1
        }
        removeCurrent(toBack: true)
        checkAutoHint()
    }

    func hudDidTapGBR() {
        if isOver {
            return
        }
        if currentNode == nil {
            return
        }
        if gbrPending {
            return
        }
        AudioManager.shared.play(.alarm)
        Haptics.shared.play(.warning)
        var m = desk
        let ok: Bool = m.handle(.callGBR)
        if ok == false {
            return
        }
        desk = m
        gbrPending = true
        hud?.setGBR(true)
        hud?.setActionsEnabled(false)
        guard let w = world else {
            return
        }
        swat.dispatch(in: w.scene) { [weak self] in
            guard let s = self else {
                return
            }
            s.gbrPending = false
            s.hud?.setGBR(false)
            var mm = s.desk
            let _ = mm.handle(.gbrArrived)
            s.desk = mm
            if s.isOver {
                return
            }
            if s.currentIsAnomaly {
                AudioManager.shared.play(.success)
                s.servedCount = s.servedCount + 1
                s.hud?.setHint("ГБР нейтрализовала аномалию.")
            } else {
                s.addComplaint()
                s.servedCount = s.servedCount + 1
                s.hud?.setHint("Ложный вызов. Жалоба.")
            }
            s.removeCurrent(toBack: true)
            s.checkAutoHint()
        }
    }

    func hudDidTapScan() {
        if isOver {
            return
        }
        if currentNode == nil {
            return
        }
        var m = desk
        if m.state != .clientArrived {
            return
        }
        let ok: Bool = m.handle(.scanStart)
        if ok == false {
            return
        }
        desk = m
        AudioManager.shared.play(.scan)
        hud?.setActionsEnabled(false)
        if let sc = scanOverlay {
            sc.frame = CGRect(x: 0, y: 80, width: view.bounds.width, height: 220)
            sc.start()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Tuning.scanDurationSec) { [weak self] in
            guard let s = self else {
                return
            }
            if s.isOver {
                return
            }
            s.scanOverlay?.stop()
            var mm = s.desk
            if mm.state == .scanning {
                let _ = mm.handle(.scanDone)
                s.desk = mm
            }
            s.hud?.setActionsEnabled(true)
            s.scanRevealed = true
            if s.currentIsAnomaly {
                s.hud?.setHint("Сканер: АНОМАЛИЯ! Не выдавать!")
                s.world?.monitor.showNoise()
            } else {
                s.hud?.setHint("Сканер: человек. Можно выдавать.")
                s.world?.monitor.showPVZ()
            }
        }
    }

    func hudDidTapCloseShift() {
        if isOver {
            return
        }
        AudioManager.shared.play(.click)
        if servedCount < plan.clientsTotal {
            hud?.setHint("Ещё остались клиенты: \(servedCount)/\(plan.clientsTotal)")
            return
        }
        winNight()
    }

    func hudDidTapPause() {
        AudioManager.shared.play(.click)
        pauseView?.isHidden = false
    }

    private func addComplaint() {
        complaints = complaints + 1
        hud?.setComplaints(complaints)
        Haptics.shared.play(.warning)
        AudioManager.shared.play(.fail)
        if complaints >= Tuning.complaintsLimit {
            failComplaints()
        }
    }

    private func checkAutoHint() {
        hud?.setComplaints(complaints)
        if clientIndex + 1 >= plan.clientsTotal && servedCount >= plan.clientsTotal {
            hud?.setHint("Все обслужены. Закройте смену.")
        }
    }

    private func failAnomaly() {
        if isOver {
            return
        }
        isOver = true
        tickTimer?.invalidate()
        ambient.stop()
        if let node = currentNode {
            animator.attack(node: node, target: SCNVector3(0, 1.5, 3.0))
        }
        world?.setFlicker(on: true)
        jumpscare.play(on: view) { [weak self] in
            guard let s = self else {
                return
            }
            s.endView?.showFail(reason: Strings.failAnomaly, onRetry: {
                AppFlow.restartNight(from: s, night: s.night)
            }, onMenu: {
                AppFlow.showMenuFrom(s)
            })
        }
    }

    private func failComplaints() {
        if isOver {
            return
        }
        isOver = true
        tickTimer?.invalidate()
        ambient.stop()
        endView?.showFail(reason: Strings.failComplaints, onRetry: { [weak self] in
            guard let s = self else {
                return
            }
            AppFlow.restartNight(from: s, night: s.night)
        }, onMenu: { [weak self] in
            guard let s = self else {
                return
            }
            AppFlow.showMenuFrom(s)
        })
    }

    private func winNight() {
        if isOver {
            return
        }
        isOver = true
        tickTimer?.invalidate()
        ambient.stop()
        AudioManager.shared.play(.success)
        Haptics.shared.play(.success)
        let isFinal: Bool = (night >= Tuning.nightsTotal)
        endView?.showWin(night: night, isFinal: isFinal, onPrimary: { [weak self] in
            guard let s = self else {
                return
            }
            if isFinal {
                AppFlow.showMenuFrom(s)
            } else {
                if let nx = NightScheduler.nextNight(after: s.night) {
                    AppFlow.restartNight(from: s, night: nx)
                } else {
                    AppFlow.showMenuFrom(s)
                }
            }
        }, onMenu: { [weak self] in
            guard let s = self else {
                return
            }
            AppFlow.showMenuFrom(s)
        })
    }

    private func resumeGame() {
        pauseView?.isHidden = true
        lastTick = Date()
    }

    private func showSettings() {
        settingsPanel?.isHidden = false
        settingsPanel?.refresh()
    }

    private func handleTap(point: CGPoint) {
        if isOver {
            return
        }
        guard let sv = scnView else {
            return
        }
        let hits = sv.hitTest(point, options: nil)
        if hits.isEmpty {
            return
        }
        AudioManager.shared.play(.click)
    }

    @objc private func toggleDebug() {
        guard let dbg = debugPanel else {
            return
        }
        if dbg.isHidden {
            dbg.isHidden = false
        } else {
            dbg.isHidden = true
        }
    }
}
