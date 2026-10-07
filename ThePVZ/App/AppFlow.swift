import UIKit

enum AppFlow {
    static func showMenu(in window: UIWindow) {
        let vc = MenuViewController()
        window.rootViewController = vc
    }

    static func showLoading(in window: UIWindow?, night: Int) {
        guard let win = window else {
            return
        }
        let vc = LoadingViewController(night: night)
        win.rootViewController = vc
    }

    static func showGame(in window: UIWindow?, night: Int) {
        guard let win = window else {
            return
        }
        let vc = GameViewController(night: night)
        win.rootViewController = vc
    }

    static func showMenuFrom(_ vc: UIViewController) {
        let menu = MenuViewController()
        menu.modalPresentationStyle = .fullScreen
        if let win = vc.view.window {
            win.rootViewController = menu
        } else {
            vc.present(menu, animated: true, completion: nil)
        }
    }

    static func restartNight(from vc: UIViewController, night: Int) {
        let game = GameViewController(night: night)
        if let win = vc.view.window {
            win.rootViewController = game
        } else {
            game.modalPresentationStyle = .fullScreen
            vc.present(game, animated: true, completion: nil)
        }
    }

    static func openTelegram(from vc: UIViewController) {
        guard let url = URL(string: GameConfig.telegramURLString) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
