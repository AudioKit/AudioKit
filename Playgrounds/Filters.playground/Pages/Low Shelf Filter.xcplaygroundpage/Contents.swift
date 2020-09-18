//: ## Low Shelf Filter
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AudioPlayer(file: file)
player.looping = true

var filter = LowShelfFilter(player)
filter.cutoffFrequency = 80 // Hz
filter.gain = 0 // dB

engine.output = filter
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Low Shelf Filter")

        addView(Button(title: "Stop") { button in
            filter.isStarted ? filter.stop() : filter.play()
            button.title = filter.isStarted ? "Stop" : "Start"
        })

        addView(Slider(property: "Cutoff Frequency",
                         value: filter.cutoffFrequency,
                         range: 10 ... 200,
                         format: "%0.1f Hz"
        ) { sliderValue in
            filter.cutoffFrequency = sliderValue
        })

        addView(Slider(property: "Gain",
                         value: filter.gain,
                         range: -40 ... 40,
                         format: "%0.1f dB"
        ) { sliderValue in
            filter.gain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
