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
        guard let urlPath = Bundle
                .main
                .path(forResource: soundFileName, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: urlPath)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            // TODO: Need testing, for now moved it to sceneDelegate
//            player.prepareToPlay() ?
            player.play()
        } catch {
            print("Error in playing sound...🙂")
        }
                
    }
}
