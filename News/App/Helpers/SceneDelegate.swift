import UIKit

@available(iOS 15.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var initialViewController: UIViewController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let userAssemblyer = UserAssemblyer.start()
        
        guard let windowScene = (scene as? UIWindowScene),
              let initialViewController = userAssemblyer.entry
        else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: initialViewController)
        configureSearchController(in: initialViewController)
        
        self.window = window
        self.initialViewController = initialViewController
        
        window.makeKeyAndVisible()
        
        guard let shortcutItem = connectionOptions.shortcutItem else { return }
        shortActionTapped(shortcutItem: shortcutItem)
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        shortActionTapped(shortcutItem: shortcutItem)
    }
}

extension SceneDelegate {
    private func configureSearchController(in rootViewController: UIViewController) {
        let searchVC = UISearchController()
        rootViewController.navigationItem.searchController = searchVC
        searchVC.searchBar.keyboardType = .asciiCapable
        searchVC.searchBar.delegate = rootViewController as? UISearchBarDelegate
        searchVC.searchBar.placeholder = "Enter the keyword"
    }
    
    private func shortActionTapped(shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
            case ShortcutItemTypes.share.rawValue:
                shareApp()
            case ShortcutItemTypes.settings.rawValue:
                openSettings()
            case ShortcutItemTypes.search.rawValue:
                search()
            default:
                break
        }
    }
    
    private func shareApp() {
        guard let initialViewController else { return }
        let shareInfo = DeveloperInfo.shareInfo.rawValue
        let activityVC = UIActivityViewController(activityItems: [shareInfo], applicationActivities: nil)
        activityVC.prepairForIPad(withVCView: initialViewController.view, withVC: initialViewController)
        // For some reason close button doesn't work, so i made my own
        initialViewController.injectCloseButton()
        initialViewController.present(activityVC, animated: true)
    }
    
    private func openSettings() {
        guard let navigationController = initialViewController?.navigationController else { return }
        navigationController.pushViewController(SettingsViewController(), animated: true)
    }
    
    private func search() {
        guard let initialViewController else { return }
        initialViewController.navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
}

private enum ShortcutItemTypes: String {
    case settings = "OpenSettingsAction"
    case share = "ShareAction"
    case search = "SearchAction"
}
