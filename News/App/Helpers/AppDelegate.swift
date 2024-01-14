import UIKit
import CoreData
import AVKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SoundManager.shared.player.prepareToPlay()
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
        configureNotifications()
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SoundManager.shared.player.stop()
    }
}

extension AppDelegate {
    private func configureNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options:  [.alert, .badge, .carPlay, .providesAppNotificationSettings, .sound]) { granted, error in
            guard error == nil, granted else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "News"
            content.body = "More topics arrived"
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "notification.mp3"))
            
            var dateComponents = DateComponents()
            dateComponents.weekday = 6
            dateComponents.hour = 17
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let uuid = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuid,
                                                content: content,
                                                trigger: trigger)
            
            notificationCenter.getPendingNotificationRequests { requests in
                if requests.isEmpty {
                    notificationCenter.add(request)
                }
            }
        }
    }
}
