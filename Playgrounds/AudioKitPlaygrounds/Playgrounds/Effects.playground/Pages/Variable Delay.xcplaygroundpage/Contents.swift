//: ## Variable Delay
//: When you smoothly vary effect parameters, you get completely new kinds of effects.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AKAudioPlayer(file: file)
player.looping = true

var delay = AKVariableDelay(player)
delay.rampDuration = 0.2
AudioKit.output = AKMixer(player, delay)

try AudioKit.start()

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Variable Delay")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Time", value: delay.time) { sliderValue in
            delay.time = sliderValue
        })
        addView(AKSlider(property: "Feedback", value: delay.feedback) { sliderValue in
            delay.feedback = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
