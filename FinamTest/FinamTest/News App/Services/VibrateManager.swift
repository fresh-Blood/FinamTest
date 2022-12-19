import Foundation
import UIKit

struct VibrateManager {
    static let shared = VibrateManager()
    
    func makeLoadingResultVibration() {
        UIImpactFeedbackGenerator().prepare()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func makeErrorVibration() {
        UINotificationFeedbackGenerator().prepare()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    func makeWarningVibration() {
        UINotificationFeedbackGenerator().prepare()
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
