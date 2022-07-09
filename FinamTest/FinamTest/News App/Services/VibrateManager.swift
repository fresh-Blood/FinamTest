import Foundation
import UIKit

struct VibrateManager {
    static let shared = VibrateManager()
    
    func makeLoadingResultVibration() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func makeErrorVibration() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    func makeWarningVibration() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
