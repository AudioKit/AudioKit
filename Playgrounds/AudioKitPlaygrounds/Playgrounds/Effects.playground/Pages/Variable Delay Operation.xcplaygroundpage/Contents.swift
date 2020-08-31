//: ## Variable Delay Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, parameters in
    let time = AKOperation.sineWave(frequency: parameters[1])
        .scale(minimum: 0.001, maximum: parameters[0])
    let feedback = AKOperation.sineWave(frequency: parameters[2])
        .scale(minimum: 0.5, maximum: 0.9)
    return player.variableDelay(time: time,
                                feedback: feedback,
                                maximumDelayTime: 1.0)
}
effect.parameters = [0.2, 0.3, 0.21]

engine.output = effect
try engine.start()
player.play()

//: User Interface
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Variable Delay Operation")
        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Maximum Delay",
                         value: effect.parameters[0],
                         range: 0 ... 0.3,
                         format: "%0.3f s"
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addView(AKSlider(property: "Delay Frequency",
                         value: effect.parameters[1],
                         format: "%0.3f Hz"
        ) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addView(AKSlider(property: "Feedback Frequency",
                         value: effect.parameters[2],
                         format: "%0.3f Hz"
        ) { sliderValue in
            effect.parameters[2] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
