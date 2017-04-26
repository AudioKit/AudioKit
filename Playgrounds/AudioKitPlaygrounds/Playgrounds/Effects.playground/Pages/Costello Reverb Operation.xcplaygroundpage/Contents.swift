//: ## Costello Reverb Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

var player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, _ in
    return player.reverberateWithCostello(
        feedback: AKOperation.sineWave(frequency: 0.1).scale(minimum: 0.5, maximum: 0.97),
        cutoffFrequency: 10_000)
}

AudioKit.output = effect
AudioKit.start()
player.play()

//: User Interface

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Costello Reverb Operation")
        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
