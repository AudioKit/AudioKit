//: ## Dynamics Processor
//: The DynamicsProcessor is both a compressor and an expander based on
//: Apple's Dynamics Processor audio unit. threshold and headRoom (similar to
//: 'ratio' you might be more familiar with) are specific to the compressor,
//: expansionRatio and expansionThreshold control the expander.

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var effect = DynamicsProcessor(player)
effect.threshold
effect.headRoom
effect.expansionRatio
effect.expansionThreshold
effect.attackDuration
effect.releaseDuration
effect.masterGain

engine.output = effect
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Dynamics Processor")

        addView(Button(title: "Stop Dynamics Processor") { button in
            let node = effect
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Dynamics Processor" : "Start Dynamics Processor"
        })

        addView(Slider(property: "Threshold",
                         value: effect.threshold,
                         range: -40 ... 20,
                         format: "%0.2f dB"
        ) { sliderValue in
            effect.threshold = sliderValue
        })

        addView(Slider(property: "Head Room",
                         value: effect.headRoom,
                         range: 0.1 ... 40,
                         format: "%0.2f dB"
        ) { sliderValue in
            effect.headRoom = sliderValue
        })

        addView(Slider(property: "Expansion Ratio",
                         value: effect.expansionRatio,
                         range: 1 ... 50
        ) { sliderValue in
            effect.expansionRatio = sliderValue
        })

        addView(Slider(property: "Expansion Threshold",
                         value: effect.expansionThreshold,
                         range: 1 ... 50
        ) { sliderValue in
            effect.expansionThreshold = sliderValue
        })

        addView(Slider(property: "Attack Duration",
                         value: effect.attackDuration,
                         range: 0.000_1 ... 0.2,
                         format: "%0.3f s"
        ) { sliderValue in
            effect.attackDuration = sliderValue
        })

        addView(Slider(property: "Release Duration",
                         value: effect.releaseDuration,
                         range: 0.01 ... 3,
                         format: "%0.3f s"
        ) { sliderValue in
            effect.releaseDuration = sliderValue
        })

        addView(Slider(property: "Master Gain",
                         value: effect.masterGain,
                         range: -40 ... 40,
                         format: "%0.2f dB"
        ) { sliderValue in
            effect.masterGain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
