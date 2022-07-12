import Foundation
import AVKit


struct SoundManager {
    static var shared = SoundManager()
    var player = AVAudioPlayer()
    var randomRefreshJedySound: String {
        let refreshJedySounds = [SoundName.jedy1.rawValue, SoundName.jedy2.rawValue]
        return refreshJedySounds.randomElement() ?? ""
    }
    
    mutating func playSound(soundFileName: String) {
        guard let soundOn = StorageService.shared.getData(for: SettingsKeys.soundSettings.rawValue) else { return }
        guard soundOn else { return }
        guard let urlPath = Bundle
                .main
                .path(forResource: soundFileName, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: urlPath)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            if FirstTimePlayingSessionMarker.playCount == .zero {
                player.volume = 0.3
                FirstTimePlayingSessionMarker.playCount += 1
            }
            player.play()
        } catch {
            print("Error in playing sound...🙂")
        }
    }
}

// To make lower the volume of load sound ( it is louder than jedy's ones)
struct FirstTimePlayingSessionMarker {
    static var playCount = 0
}
