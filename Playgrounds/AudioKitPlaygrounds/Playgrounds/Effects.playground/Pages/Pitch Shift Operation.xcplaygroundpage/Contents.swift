//: ## Pitch Shift Operation
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let effect = OperationEffect(player) { player, parameters in
    let sinusoid = Operation.sineWave(frequency: parameters[2])
    let shift = parameters[0] + sinusoid * parameters[1] / 2.0
    return player.pitchShift(semitones: shift)
}
effect.parameters = [0, 7, 3]

engine.output = effect
try engine.start()
player.play()


class LiveView: View {

    override func viewDidLoad() {
        addTitle("Pitch Shift Operation")
        addView(Slider(property: "Base Shift",
                         value: effect.parameters[0],
                         range: -12 ... 12,
                         format: "%0.3f semitones"
        ) { sliderValue in
            effect.parameters[0] = sliderValue
        })
        addView(Slider(property: "Range",
                         value: effect.parameters[1],
                         range: 0 ... 24,
                         format: "%0.3f semitones"
        ) { sliderValue in
            effect.parameters[1] = sliderValue
        })
        addView(Slider(property: "Speed",
                         value: effect.parameters[2],
                         range: 0.001 ... 10,
                         format: "%0.3f Hz"
        ) { sliderValue in
            effect.parameters[2] = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
