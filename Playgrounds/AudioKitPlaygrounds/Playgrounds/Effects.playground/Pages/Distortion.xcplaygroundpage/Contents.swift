//: ## Distortion
//: This thing is a beast.
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var distortion = AKDistortion(player)
distortion.delay = 0.1
distortion.decay = 1.0
distortion.delayMix = 0.5
distortion.linearTerm = 0.5
distortion.squaredTerm = 0.5
distortion.cubicTerm = 50
distortion.polynomialMix = 0.5
distortion.softClipGain = -6
distortion.finalMix = 0.5

engine.output = AKBooster(distortion, gain: 0.1)
try engine.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    var delaySlider: AKSlider!
    var decaySlider: AKSlider!
    var delayMixSlider: AKSlider!
    var linearTermSlider: AKSlider!
    var squaredTermSlider: AKSlider!
    var cubicTermSlider: AKSlider!
    var polynomialMixSlider: AKSlider!
    var softClipGainSlider: AKSlider!
    var finalMixSlider: AKSlider!

    override func viewDidLoad() {
        addTitle("Distortion")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKButton(title: "Stop Distortion") { button in
            let node = distortion
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Distortion" : "Start Distortion"
        })

        delaySlider = AKSlider(property: "Delay",
                               value: distortion.delay,
                               range: 0.1 ... 500,
                               format: "%0.3f ms"
        ) { sliderValue in
            distortion.delay = sliderValue
        }
        addView(delaySlider)

        decaySlider = AKSlider(property: "Decay Rate",
                               value: distortion.decay,
                               range: 0.1 ... 50
        ) { sliderValue in
            distortion.decay = sliderValue
        }
        addView(decaySlider)

        addView(AKSlider(property: "Delay Mix", value: distortion.delayMix) { sliderValue in
            distortion.delayMix = sliderValue
        })

        addView(AKSlider(property: "Linear Term", value: distortion.linearTerm) { sliderValue in
            distortion.linearTerm = sliderValue
        })

        addView(AKSlider(property: "Squared Term", value: distortion.squaredTerm) { sliderValue in
            distortion.squaredTerm = sliderValue
        })

        addView(AKSlider(property: "Cubic Term", value: distortion.cubicTerm) { sliderValue in
            distortion.cubicTerm = sliderValue
        })

        addView(AKSlider(property: "Polynomial Mix", value: distortion.polynomialMix) { sliderValue in
            distortion.polynomialMix = sliderValue
        })

        softClipGainSlider = AKSlider(property: "Soft Clip Gain",
                                      value: distortion.softClipGain,
                                      range: -80 ... 20,
                                      format: "%0.3f dB"
        ) { sliderValue in
            distortion.softClipGain = sliderValue
        }
        addView(softClipGainSlider)

        addView(AKSlider(property: "Final Mix", value: distortion.finalMix) { sliderValue in
            distortion.finalMix = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
