//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mixing Nodes
//: So, what about connecting multiple sources to the output instead of
//: feeding operations into each other in sequential order? To do that, you'll need a mixer.
import AudioKitPlaygrounds
import AudioKit
//: This section prepares the players
let drumFile = try AKAudioFile(readFileName: "drumloop.wav")
let bassFile = try AKAudioFile(readFileName: "bassloop.wav")
let guitarFile = try AKAudioFile(readFileName: "guitarloop.wav")
let leadFile = try AKAudioFile(readFileName: "leadloop.wav")

var drums = AKPlayer(audioFile: drumFile)
var bass = AKPlayer(audioFile: bassFile)
var guitar = AKPlayer(audioFile: guitarFile)
var lead = AKPlayer(audioFile: leadFile)

drums.isLooping = true
drums.buffering = .always
bass.isLooping = true
bass.buffering = .always
guitar.isLooping = true
guitar.buffering = .always
lead.isLooping = true
lead.buffering = .always

//: Any number of inputs can be summed into one output
let mixer = AKMixer(drums, bass, guitar, lead)
let booster = AKBooster(mixer)
AudioKit.output = booster
try AudioKit.start()

drums.play()
bass.play()
guitar.play()
lead.play()

//: Adjust the individual track volumes here
drums.volume = 0.9
bass.volume = 0.9
guitar.volume = 0.6
lead.volume = 0.7

drums.pan = 0.0
bass.pan = 0.0
guitar.pan = 0.2
lead.pan   = -0.2

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Mixer")

        addView(AKButton(title: "Stop All") { button in
            drums.isPlaying  ? drums.stop()  : drums.play()
            bass.isPlaying   ? bass.stop()   : bass.play()
            guitar.isPlaying ? guitar.stop() : guitar.play()
            lead.isPlaying   ? lead.stop()   : lead.play()

            if drums.isPlaying {
                button.title = "Stop All"
            } else {
                button.title = "Start All"
            }
        })

        addView(AKSlider(property: "Drums Volume", value: drums.volume) { sliderValue in
            drums.volume = sliderValue
        })
        addView(AKSlider(property: "Drums Pan", value: drums.pan, range: -1 ... 1) { sliderValue in
            drums.pan = sliderValue
        })

        addView(AKSlider(property: "Bass Volume", value: bass.volume) { sliderValue in
            bass.volume = sliderValue
        })
        addView(AKSlider(property: "Bass Pan", value: bass.pan, range: -1 ... 1) { sliderValue in
            bass.pan = sliderValue
        })

        addView(AKSlider(property: "Guitar Volume", value: guitar.volume) { sliderValue in
            guitar.volume = sliderValue
        })
        addView(AKSlider(property: "Guitar Pan", value: guitar.pan, range: -1 ... 1) { sliderValue in
            guitar.pan = sliderValue
        })

        addView(AKSlider(property: "Lead Volume", value: lead.volume) { sliderValue in
            lead.volume = sliderValue
        })
        addView(AKSlider(property: "Lead Pan", value: lead.pan, range: -1 ... 1) { sliderValue in
            lead.pan = sliderValue
        })

        addView(AKSlider(property: "Overall Volume", value: booster.gain, range: 0 ... 2) { sliderValue in
            booster.gain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
