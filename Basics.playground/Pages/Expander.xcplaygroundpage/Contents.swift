//: ## Expander
//: ##

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var expander = Expander(player)

engine.output = expander
try engine.start()

player.play()

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Expander")

        addView(Button(title: "Stop Expander") { button in
            let node = expander
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Expander" : "Start Expander"
        })

        addView(Slider(property: "Ratio",
                         value: expander.expansionRatio,
                         range: 1 ... 50,
                         format: "%0.2f"
        ) { sliderValue in
            expander.expansionRatio = sliderValue
        })

        addView(Slider(property: "Threshold",
                         value: expander.expansionThreshold,
                         range: 1 ... 50,
                         format: "%0.2f"
        ) { sliderValue in
            expander.expansionThreshold = sliderValue
        })
        addView(Slider(property: "Attack Duration",
                         value: expander.attackDuration,
                         range: 0.001 ... 0.2,
                         format: "%0.4f s"
        ) { sliderValue in
            expander.attackDuration = sliderValue
        })
        addView(Slider(property: "Release Duration",
                         value: expander.releaseDuration,
                         range: 0.01 ... 3,
                         format: "%0.3f s"
        ) { sliderValue in
            expander.releaseDuration = sliderValue
        })
        addView(Slider(property: "Master Gain",
                         value: expander.masterGain,
                         range: -40 ... 40,
                         format: "%0.2f dB"
        ) { sliderValue in
            expander.masterGain = sliderValue
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
