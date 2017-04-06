//: ## Smooth Delay Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

var player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, parameters in
    let delayedPlayer = player.smoothDelay(
        time: parameters[0],
        samples: 1_024,
        feedback: parameters[1],
        maximumDelayTime: 2.0)
    return mixer(player.toMono(), delayedPlayer)
}
effect.parameters = [0.1, 0.7]

AudioKit.output = effect
AudioKit.start()
player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Smooth Delay Operation")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Time",
            value: effect.parameters[0],
            color: AKColor.green
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Feedback",
            value: effect.parameters[1],
            color: AKColor.red
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
    }

}

import PlaygroundSupport
PlaygroundPage.current.liveView = PlaygroundView()
PlaygroundPage.current.needsIndefiniteExecution = true
