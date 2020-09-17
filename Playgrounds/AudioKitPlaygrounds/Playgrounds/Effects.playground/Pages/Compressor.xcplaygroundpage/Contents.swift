//: ## Compressor
//: ##

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var compressor = Compressor(player)

engine.output = compressor
try engine.start()

player.play()

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Compressor")

        addView(Button(title: "Stop Compressor") { button in
            let node = compressor
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Compressor" : "Start Compressor"
        })

        addView(Slider(property: "Threshold",
                         value: compressor.threshold,
                         range: -40 ... 20,
                         format: "%0.2f dB"
        ) { sliderValue in
            compressor.threshold = sliderValue
        })
        addView(Slider(property: "Headroom",
                         value: compressor.headRoom,
                         range: 0.1 ... 40,
                         format: "%0.2f dB"
        ) { sliderValue in
            compressor.headRoom = sliderValue
        })
        addView(Slider(property: "Attack Duration",
                         value: compressor.attackDuration,
                         range: 0.001 ... 0.2,
                         format: "%0.4f s"
        ) { sliderValue in
            compressor.attackDuration = sliderValue
        })
        addView(Slider(property: "Release Duration",
                         value: compressor.releaseDuration,
                         range: 0.01 ... 3,
                         format: "%0.3f s"
        ) { sliderValue in
            compressor.releaseDuration = sliderValue
        })
        addView(Slider(property: "Master Gain",
                         value: compressor.masterGain,
                         range: -40 ... 40,
                         format: "%0.2f dB"
        ) { sliderValue in
            compressor.masterGain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
