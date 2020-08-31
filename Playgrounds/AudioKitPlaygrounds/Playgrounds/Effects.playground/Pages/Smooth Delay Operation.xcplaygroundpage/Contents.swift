//: ## Smooth Delay Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, parameters in
    let delayedPlayer = player.smoothDelay(
        time: parameters[0],
        feedback: parameters[1],
        samples: 1_024,
        maximumDelayTime: 2.0)
    return mixer(player.toMono(), delayedPlayer)
}
effect.parameters = [0.1, 0.7]

engine.output = effect
try engine.start()
player.play()

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Smooth Delay Operation")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Time", value: effect.parameters[0]) { sliderValue in
            effect.parameters[0] = sliderValue
        })

        addView(AKSlider(property: "Feedback", value: effect.parameters[1]) { sliderValue in
            effect.parameters[1] = sliderValue
        })
    }

}

import PlaygroundSupport
PlaygroundPage.current.liveView = LiveView()
PlaygroundPage.current.needsIndefiniteExecution = true
