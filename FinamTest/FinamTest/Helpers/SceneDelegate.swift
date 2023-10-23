import UIKit

@available(iOS 15.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let userAssemblyer = UserAssemblyer.start()
        let initialVC = userAssemblyer.entry
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: initialVC!)
        self.window = window
        window.makeKeyAndVisible()
    }
}

