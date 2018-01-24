//: ## Costello Reverb Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

var player = AKPlayer(audioFile: file)
player.isLooping = true

let effect = AKOperationEffect(player) { player, _ in
    return player.reverberateWithCostello(
        feedback: AKOperation.sineWave(frequency: 0.1).scale(minimum: 0.5, maximum: 0.97),
        cutoffFrequency: 10_000)
}

AudioKit.output = effect
try AudioKit.start()
player.play()

//: User Interface
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Costello Reverb Operation")
        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
