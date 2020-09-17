//: ## Ring Modulator
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var ringModulator = RingModulator(player)
ringModulator.frequency1 = 440 // Hz
ringModulator.frequency2 = 660 // Hz
ringModulator.balance = 0.5
ringModulator.mix = 0.5

engine.output = ringModulator
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Ring Modulator")

        addView(Button(title: "Stop Ring Modulator") { button in
            let node = ringModulator
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Ring Modulator" : "Start Ring Modulator"
        })

        addView(Slider(property: "Frequency 1",
                         value: ringModulator.frequency1,
                         range: 0.5 ... 8_000,
                         format: "%0.2f Hz"
        ) { sliderValue in
            ringModulator.frequency1 = sliderValue
        })

        addView(Slider(property: "Frequency 2",
                         value: ringModulator.frequency2,
                         range: 0.5 ... 8_000,
                         format: "%0.2f Hz"
        ) { sliderValue in
            ringModulator.frequency2 = sliderValue
        })

        addView(Slider(property: "Balance", value: ringModulator.balance) { sliderValue in
            ringModulator.balance = sliderValue
        })

        addView(Slider(property: "Mix", value: ringModulator.mix) { sliderValue in
            ringModulator.mix = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
