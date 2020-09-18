//: ## Stereo Delay Operation
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let effect = OperationEffect(player, channelCount: 2) { _, parameters in
    let leftDelay = Operation.leftInput.variableDelay(time: parameters[0], feedback: parameters[1])
    let rightDelay = Operation.rightInput.variableDelay(time: parameters[2], feedback: parameters[3])
    return [leftDelay, rightDelay]
}
effect.parameters = [0.2, 0.5, 0.01, 0.9]

engine.output = effect
try engine.start()
player.play()

//: User Interface

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Stereo Delay Operation")
        addView(Slider(property: "Left Delay",
                         value: effect.parameters[0],
                         range: 0 ... 0.3,
                         format: "%0.3f s"
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addView(Slider(property: "Left Feedback", value: effect.parameters[1]) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addView(Slider(property: "Right Delay",
                         value: effect.parameters[2],
                         range: 0 ... 0.3,
                         format: "%0.3f s"
        ) { sliderValue in
            effect.parameters[2] = sliderValue
        })
        addView(Slider(property: "Right Feedback", value: effect.parameters[3]) { sliderValue in
            effect.parameters[3] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
