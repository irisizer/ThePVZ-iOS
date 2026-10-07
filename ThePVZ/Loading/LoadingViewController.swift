import UIKit

final class LoadingViewController: UIViewController {
    private let night: Int
    private var bar: UIProgressView?
    private var label: UILabel?

    init(night: Int) {
        self.night = night
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.night = 1
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bgDeep
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = Strings.night(night)
        l.textColor = Palette.neonPink
        l.font = Fonts.make(role: .title, size: 28.0)
        l.textAlignment = .center
        view.addSubview(l)
        label = l
        let b = UIProgressView(progressViewStyle: .default)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.progressTintColor = Palette.neonPink
        b.trackTintColor = Palette.bgPurple
        view.addSubview(b)
        bar = b
        NSLayoutConstraint.activate([
            l.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            l.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30.0),
            b.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            b.topAnchor.constraint(equalTo: l.bottomAnchor, constant: 20.0),
            b.widthAnchor.constraint(equalToConstant: 240.0)
        ])
        startLoading()
    }

    private func startLoading() {
        let loader = Loader()
        loader.load(progress: { [weak self] v in
            DispatchQueue.main.async {
                self?.bar?.setProgress(Float(v), animated: true)
            }
        }, completion: { [weak self] in
            DispatchQueue.main.async {
                guard let s = self else {
                    return
                }
                AppFlow.showGame(in: s.view.window, night: s.night)
            }
        })
    }
}
