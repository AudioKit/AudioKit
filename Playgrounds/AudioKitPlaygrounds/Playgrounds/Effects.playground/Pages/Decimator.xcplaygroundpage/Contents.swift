//: ## Decimator
//: Decimation is a type of digital distortion like bit crushing,
//: but instead of directly stating what bit depth and sample rate you want,
//: it is done through setting "decimation" and "rounding" parameters.

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

//: Next, we'll connect the audio sources to a decimator
var decimator = Decimator(player)
decimator.decimation = 0.5 // Normalized Value 0 - 1
decimator.rounding = 0.5 // Normalized Value 0 - 1
decimator.mix = 0.5 // Normalized Value 0 - 1

engine.output = decimator
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Decimator")

        addView(Slider(property: "Decimation", value: decimator.decimation) { sliderValue in
            decimator.decimation = sliderValue
        })

        addView(Slider(property: "Rounding", value: decimator.rounding) { sliderValue in
            decimator.rounding = sliderValue
        })

        addView(Slider(property: "Mix", value: decimator.mix) { sliderValue in
            decimator.mix = sliderValue
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
