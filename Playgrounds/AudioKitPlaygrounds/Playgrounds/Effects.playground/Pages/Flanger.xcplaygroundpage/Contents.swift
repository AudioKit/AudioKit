//: ## Flanger

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var flanger = Flanger(player)

engine.output = flanger

try engine.start()

player.play()

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Flanger")

        addView(Slider(property: "Feedback",
                         value: flanger.feedback,
                         range: -0.95 ... 0.95) { sliderValue in
            flanger.feedback = sliderValue
        })

        addView(Slider(property: "Depth", value: flanger.depth) { sliderValue in
            flanger.depth = sliderValue
        })

        addView(Slider(property: "Dry Wet Mix", value: flanger.dryWetMix) { sliderValue in
            flanger.dryWetMix = sliderValue
        })

        addView(Slider(property: "Frequency",
                         value: flanger.frequency,
                         range: 0.1 ... 10,
                         format: "%0.1f Hz"
        ) { sliderValue in
            flanger.frequency = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
