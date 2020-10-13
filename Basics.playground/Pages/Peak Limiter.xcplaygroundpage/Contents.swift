//: ## Peak Limiter
//: A peak limiter will set a hard limit on the amplitude of an audio signal.
//: They're espeically useful for any type of live input processing, when you
//: may not be in total control of the audio signal you're recording or processing.

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var peakLimiter = PeakLimiter(player)
peakLimiter.attackDuration = 0.001 // Secs
peakLimiter.decayDuration = 0.01 // Secs
peakLimiter.preGain = 10 // dB

engine.output = peakLimiter
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Peak Limiter")

        addView(Button(title: "Stop Limiter") { button in
            let node = peakLimiter
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Limiter" : "Start Limiter"
        })

        addView(Slider(property: "Attack Duration",
                         value: peakLimiter.attackDuration,
                         range: 0.001 ... 0.03,
                         format: "%0.3f s"
        ) { sliderValue in
            peakLimiter.attackDuration = sliderValue
        })

        addView(Slider(property: "Decay Duration",
                         value: peakLimiter.decayDuration,
                         range: 0.001 ... 0.03,
                         format: "%0.3f s"
        ) { sliderValue in
            peakLimiter.decayDuration = sliderValue
        })

        addView(Slider(property: "Pre-gain",
                         value: peakLimiter.preGain,
                         range: -40 ... 40,
                         format: "%0.1f dB"
        ) { sliderValue in
            peakLimiter.preGain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
