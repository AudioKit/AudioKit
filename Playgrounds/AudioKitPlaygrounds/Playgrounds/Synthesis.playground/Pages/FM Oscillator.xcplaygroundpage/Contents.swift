//: ## FM Oscillator
//: Open the timeline view to use the controls this playground sets up.
//:

import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
oscillator.rampTime = 0.1
AudioKit.output = oscillator
AudioKit.start()

class PlaygroundView: AKPlaygroundView {

    // UI Elements we'll need to be able to access
    var frequencySlider: AKSlider!
    var carrierMultiplierSlider: AKSlider!
    var modulatingMultiplierSlider: AKSlider!
    var modulationIndexSlider: AKSlider!
    var amplitudeSlider: AKSlider!
    var rampTimeSlider: AKSlider!

    override func setup() {
        addTitle("FM Oscillator")

        addSubview(AKBypassButton(node: oscillator))

        let presets = ["Stun Ray", "Wobble", "Fog Horn", "Buzzer", "Spiral"]
        addSubview(AKPresetLoaderView(presets: presets) { preset in
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
            self.rampTimeSlider?.value = oscillator.rampTime
        })

        addSubview(AKButton(title: "Randomize") { _ in
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
        addSubview(frequencySlider)

        carrierMultiplierSlider = AKSlider(property: "Carrier Multiplier",
                                           value: oscillator.carrierMultiplier,
                                           range: 0 ... 20
        ) { multiplier in
            oscillator.carrierMultiplier = multiplier
        }
        addSubview(carrierMultiplierSlider)

        modulatingMultiplierSlider = AKSlider(property: "Modulating Multiplier",
                                              value: oscillator.modulatingMultiplier,
                                              range: 0 ... 20
        ) { multiplier in
            oscillator.modulatingMultiplier = multiplier
        }
        addSubview(modulatingMultiplierSlider)

        modulationIndexSlider = AKSlider(property: "Modulation Index",
                                         value: oscillator.modulationIndex,
                                         range: 0 ... 100
        ) { index in
            oscillator.modulationIndex = index
        }
        addSubview(modulationIndexSlider)

        amplitudeSlider = AKSlider(property: "Amplitude", value: oscillator.amplitude) { amplitude in
            oscillator.amplitude = amplitude
        }
        addSubview(amplitudeSlider)

        rampTimeSlider = AKSlider(property: "Ramp Time",
                                  value: oscillator.rampTime,
                                  range: 0 ... 10,
                                  format: "%0.3f s"
        ) { time in
            oscillator.rampTime = time
        }
        addSubview(rampTimeSlider)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
