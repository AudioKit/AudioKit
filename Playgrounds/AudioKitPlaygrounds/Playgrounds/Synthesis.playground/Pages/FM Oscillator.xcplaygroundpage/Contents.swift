//: ## FM Oscillator
//: Open the timeline view to use the controls this playground sets up.
//:

import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
oscillator.rampDuration = 0.1
AudioKit.output = oscillator
try AudioKit.start()

class LiveView: AKLiveViewController {

    // UI Elements we'll need to be able to access
    var frequencySlider: AKSlider!
    var carrierMultiplierSlider: AKSlider!
    var modulatingMultiplierSlider: AKSlider!
    var modulationIndexSlider: AKSlider!
    var amplitudeSlider: AKSlider!
    var rampDurationSlider: AKSlider!

    override func viewDidLoad() {
        addTitle("FM Oscillator")

        addView(AKButton(title: "Start FM Oscillator") { button in
            oscillator.isStarted ? oscillator.stop() : oscillator.play()
            button.title = oscillator.isStarted ? "Stop FM Oscillator" : "Start FM Oscillator"
        })

        let presets = ["Stun Ray", "Wobble", "Fog Horn", "Buzzer", "Spiral"]
        addView(AKPresetLoaderView(presets: presets) { preset in
            switch preset {
            case "Stun Ray":
                oscillator.presetStunRay()
                oscillator.start()
            case "Wobble":
                oscillator.presetWobble()
                oscillator.start()
            case "Fog Horn":
                oscillator.presetFogHorn()
                oscillator.start()
            case "Buzzer":
                oscillator.presetBuzzer()
                oscillator.start()
            case "Spiral":
                oscillator.presetSpiral()
                oscillator.start()
            default:
                break
            }
            self.frequencySlider?.value = oscillator.baseFrequency
            self.carrierMultiplierSlider?.value = oscillator.carrierMultiplier
            self.modulatingMultiplierSlider?.value = oscillator.modulatingMultiplier
            self.modulationIndexSlider?.value = oscillator.modulationIndex
            self.amplitudeSlider?.value = oscillator.amplitude
            self.rampDurationSlider?.value = oscillator.rampDuration
        })

        addView(AKButton(title: "Randomize") { _ in
            oscillator.baseFrequency = self.frequencySlider.randomize()
            oscillator.carrierMultiplier = self.carrierMultiplierSlider.randomize()
            oscillator.modulatingMultiplier = self.modulatingMultiplierSlider.randomize()
            oscillator.modulationIndex = self.modulationIndexSlider.randomize()
        })

        frequencySlider = AKSlider(property: "Frequency",
                                   value: oscillator.baseFrequency,
                                   range: 0 ... 800,
                                   format: "%0.2f Hz"
        ) { frequency in
            oscillator.baseFrequency = frequency
        }
        addView(frequencySlider)

        carrierMultiplierSlider = AKSlider(property: "Carrier Multiplier",
                                           value: oscillator.carrierMultiplier,
                                           range: 0 ... 20
        ) { multiplier in
            oscillator.carrierMultiplier = multiplier
        }
        addView(carrierMultiplierSlider)

        modulatingMultiplierSlider = AKSlider(property: "Modulating Multiplier",
                                              value: oscillator.modulatingMultiplier,
                                              range: 0 ... 20
        ) { multiplier in
            oscillator.modulatingMultiplier = multiplier
        }
        addView(modulatingMultiplierSlider)

        modulationIndexSlider = AKSlider(property: "Modulation Index",
                                         value: oscillator.modulationIndex,
                                         range: 0 ... 100
        ) { index in
            oscillator.modulationIndex = index
        }
        addView(modulationIndexSlider)

        amplitudeSlider = AKSlider(property: "Amplitude", value: oscillator.amplitude) { amplitude in
            oscillator.amplitude = amplitude
        }
        addView(amplitudeSlider)

        rampDurationSlider = AKSlider(property: "Ramp Duration",
                                  value: oscillator.rampDuration,
                                  range: 0 ... 10,
                                  format: "%0.3f s"
        ) { time in
            oscillator.rampDuration = time
        }
        addView(rampDurationSlider)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
