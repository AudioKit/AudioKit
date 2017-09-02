//: ## Stereo Delay Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player, numberOfChannels: 2) { _, parameters in
    let leftDelay = AKOperation.leftInput.variableDelay(time: parameters[0], feedback: parameters[1])
    let rightDelay = AKOperation.rightInput.variableDelay(time: parameters[2], feedback: parameters[3])
    return [leftDelay, rightDelay]
}
effect.parameters = [0.2, 0.5, 0.01, 0.9]

AudioKit.output = effect
AudioKit.start()
player.play()

//: User Interface
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Stereo Delay Operation")
        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKSlider(property: "Left Delay",
                            value: effect.parameters[0],
                            range: 0 ... 0.3,
                            format: "%0.3f s"
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addSubview(AKSlider(property: "Left Feedback", value: effect.parameters[1]) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addSubview(AKSlider(property: "Right Delay",
                            value: effect.parameters[2],
                            range: 0 ... 0.3,
                            format: "%0.3f s"
        ) { sliderValue in
            effect.parameters[2] = sliderValue
        })
        addSubview(AKSlider(property: "Left Feedback", value: effect.parameters[3]) { sliderValue in
            effect.parameters[3] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
