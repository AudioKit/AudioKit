//: ## Fatten Effect
//: This is a cool stereo fattening effect that Matthew Fecher wanted for the
//: Analog Synth X project, so it was developed here in a playground first.

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let fatten = OperationEffect(player) { input, parameters in

    let time = parameters[0]
    let mix = parameters[1]

    let fatten = "\(input) dup \(1 - mix) * swap 0 \(time) 1.0 vdelay \(mix) * +"

    return StereoOperation(fatten)
}

engine.output = fatten
try engine.start()

player.play()

fatten.parameters = [0.1, 0.5]

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Analog Synth X Fatten")

        addView(Slider(property: "Time",
                         value: fatten.parameters[0],
                         range: 0.03 ... 0.1,
                         format: "%0.3f s"
        ) { sliderValue in
            fatten.parameters[0] = sliderValue
        })

        addView(Slider(property: "Mix", value: fatten.parameters[1]) { sliderValue in
            fatten.parameters[1] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
