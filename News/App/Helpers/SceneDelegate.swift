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
        
        guard let shortcutItem = connectionOptions.shortcutItem,
              let rootViewController = windowScene.keyWindow?.rootViewController else { return }
        shortActionTapped(shortcutItem: shortcutItem, rootViewController: rootViewController)
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let rootViewController = windowScene.keyWindow?.rootViewController else { return }
        shortActionTapped(shortcutItem: shortcutItem, rootViewController: rootViewController)
    }
    
    private func shortActionTapped(shortcutItem: UIApplicationShortcutItem, rootViewController: UIViewController) {
        switch shortcutItem.type {
            case ShortcutItemTypes.share.rawValue:
                shareApp(rootViewController: rootViewController)
            case ShortcutItemTypes.settings.rawValue:
                print("settings")
            case ShortcutItemTypes.search.rawValue:
                print("search")
            default:
                break
        }
    }
    
    private func shareApp(rootViewController: UIViewController) {
        let shareInfo = DeveloperInfo.shareInfo.rawValue
        let activityVC = UIActivityViewController(activityItems: [shareInfo], applicationActivities: nil)
        activityVC.prepairForIPad(withVCView: rootViewController.view, withVC: rootViewController)
        // For some reason close button doesn't work, so i made my own
        rootViewController.injectCloseButton()
        rootViewController.present(activityVC, animated: true)
    }
}


private enum ShortcutItemTypes: String {
    case settings = "OpenSettingsAction"
    case share = "ShareAction"
    case search = "SearchAction"
}
