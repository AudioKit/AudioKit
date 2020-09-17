//: ## Distortion
//: This thing is a beast.
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var distortion = Distortion(player)
distortion.delay = 0.1
distortion.decay = 1.0
distortion.delayMix = 0.5
distortion.linearTerm = 0.5
distortion.squaredTerm = 0.5
distortion.cubicTerm = 50
distortion.polynomialMix = 0.5
distortion.softClipGain = -6
distortion.finalMix = 0.5

engine.output = Fader(distortion, gain: 0.1)
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    var delaySlider: Slider!
    var decaySlider: Slider!
    var delayMixSlider: Slider!
    var linearTermSlider: Slider!
    var squaredTermSlider: Slider!
    var cubicTermSlider: Slider!
    var polynomialMixSlider: Slider!
    var softClipGainSlider: Slider!
    var finalMixSlider: Slider!

    override func viewDidLoad() {
        addTitle("Distortion")

        addView(Button(title: "Stop Distortion") { button in
            let node = distortion
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Distortion" : "Start Distortion"
        })

        delaySlider = Slider(property: "Delay",
                               value: distortion.delay,
                               range: 0.1 ... 500,
                               format: "%0.3f ms"
        ) { sliderValue in
            distortion.delay = sliderValue
        }
        addView(delaySlider)

        decaySlider = Slider(property: "Decay Rate",
                               value: distortion.decay,
                               range: 0.1 ... 50
        ) { sliderValue in
            distortion.decay = sliderValue
        }
        addView(decaySlider)

        addView(Slider(property: "Delay Mix", value: distortion.delayMix) { sliderValue in
            distortion.delayMix = sliderValue
        })

        addView(Slider(property: "Linear Term", value: distortion.linearTerm) { sliderValue in
            distortion.linearTerm = sliderValue
        })

        addView(Slider(property: "Squared Term", value: distortion.squaredTerm) { sliderValue in
            distortion.squaredTerm = sliderValue
        })

        addView(Slider(property: "Cubic Term", value: distortion.cubicTerm) { sliderValue in
            distortion.cubicTerm = sliderValue
        })

        addView(Slider(property: "Polynomial Mix", value: distortion.polynomialMix) { sliderValue in
            distortion.polynomialMix = sliderValue
        })

        softClipGainSlider = Slider(property: "Soft Clip Gain",
                                      value: distortion.softClipGain,
                                      range: -80 ... 20,
                                      format: "%0.3f dB"
        ) { sliderValue in
            distortion.softClipGain = sliderValue
        }
        addView(softClipGainSlider)

        addView(Slider(property: "Final Mix", value: distortion.finalMix) { sliderValue in
            distortion.finalMix = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
