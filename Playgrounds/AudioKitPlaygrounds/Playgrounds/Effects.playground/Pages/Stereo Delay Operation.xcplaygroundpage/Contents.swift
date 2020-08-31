//: ## Stereo Delay Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player, channelCount: 2) { _, parameters in
    let leftDelay = AKOperation.leftInput.variableDelay(time: parameters[0], feedback: parameters[1])
    let rightDelay = AKOperation.rightInput.variableDelay(time: parameters[2], feedback: parameters[3])
    return [leftDelay, rightDelay]
}
effect.parameters = [0.2, 0.5, 0.01, 0.9]

engine.output = effect
try engine.start()
player.play()

//: User Interface
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Stereo Delay Operation")
        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Left Delay",
                         value: effect.parameters[0],
                         range: 0 ... 0.3,
                         format: "%0.3f s"
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addView(AKSlider(property: "Left Feedback", value: effect.parameters[1]) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addView(AKSlider(property: "Right Delay",
                         value: effect.parameters[2],
                         range: 0 ... 0.3,
                         format: "%0.3f s"
        ) { sliderValue in
            effect.parameters[2] = sliderValue
        })
        addView(AKSlider(property: "Right Feedback", value: effect.parameters[3]) { sliderValue in
            effect.parameters[3] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
