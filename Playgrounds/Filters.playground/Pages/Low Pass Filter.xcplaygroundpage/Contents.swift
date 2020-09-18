//: ## Low Pass Filter
//: A low-pass filter takes an audio signal as an input, and cuts out the
//: high-frequency components of the audio signal, allowing for the
//: lower frequency components to "pass through" the filter.
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var filter = LowPassFilter(player)
filter.cutoffFrequency = 6_900 // Hz
filter.resonance = 0 // dB

engine.output = filter
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Low Pass Filter")

        addView(Button(title: "Stop") { button in
            filter.isStarted ? filter.stop() : filter.play()
            button.title = filter.isStarted ? "Stop" : "Start"
        })

        addView(Slider(property: "Cutoff Frequency",
                         value: filter.cutoffFrequency,
                         range: 20 ... 22_050,
                         taper: 5,
                         format: "%0.1f Hz"
        ) { sliderValue in
            filter.cutoffFrequency = sliderValue
        })

        addView(Slider(property: "Resonance",
                         value: filter.resonance,
                         range: -20 ... 40,
                         format: "%0.1f dB"
        ) { sliderValue in
            filter.resonance = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
