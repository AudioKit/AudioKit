//: ## Chorus

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var chorus = Chorus(player)

engine.output = chorus
try engine.start()

player.play()

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Chorus")

        addView(Slider(property: "Feedback",
                         value: chorus.feedback,
                         range: -0.95 ... 0.95) { sliderValue in
                            chorus.feedback = sliderValue
        })

        addView(Slider(property: "Depth", value: chorus.depth) { sliderValue in
            chorus.depth = sliderValue
        })

        addView(Slider(property: "Dry Wet Mix", value: chorus.dryWetMix) { sliderValue in
            chorus.dryWetMix = sliderValue
        })

        addView(Slider(property: "Frequency",
                         value: chorus.frequency,
                         range: 0.1 ... 10,
                         format: "%0.1f Hz"
        ) { sliderValue in
            chorus.frequency = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
