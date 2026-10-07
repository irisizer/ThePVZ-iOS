import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let ws = scene as? UIWindowScene else {
            return
        }
        let win = UIWindow(windowScene: ws)
        win.overrideUserInterfaceStyle = .dark
        self.window = win
        AppFlow.showMenu(in: win)
        win.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        AudioManager.shared.stopAll()
    }
}
