//: ## AutoPan Operation
//:

import AudioKit
//: This first section sets up parameter naming in such a way
//: to make the operation code easier to read below.

let speedIndex = 0
let depthIndex = 1

extension OperationEffect {
    var speed: Double {
        get { return self.parameters[speedIndex] }
        set(newValue) { self.parameters[speedIndex] = newValue }
    }
    var depth: Double {
        get { return self.parameters[depthIndex] }
        set(newValue) { self.parameters[depthIndex] = newValue }
    }
}

//: Use the struct and the extension to refer to the autopan parameters by name

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AudioPlayer(file: file)
player.looping = true

let effect = OperationEffect(player) { input, parameters in
    let oscillator = Operation.sineWave(frequency: parameters[speedIndex], amplitude: parameters[depthIndex])
    return input.pan(oscillator)
}

effect.parameters = [10, 1]
engine.output = effect
try engine.start()
player.play()


class LiveView: View {

    override func viewDidLoad() {
        addTitle("AutoPan")

        addView(Slider(property: "Speed", value: effect.speed, range: 0.1 ... 25) { sliderValue in
            effect.speed = sliderValue
        })

        addView(Slider(property: "Depth", value: effect.depth) { sliderValue in
            effect.depth = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
