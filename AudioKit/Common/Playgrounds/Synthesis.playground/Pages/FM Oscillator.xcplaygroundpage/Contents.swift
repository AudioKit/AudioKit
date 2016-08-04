//: ## FM Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
oscillator.rampTime = 0.1
AudioKit.output = oscillator
AudioKit.start()

class PlaygroundView: AKPlaygroundView {

    // UI Elements we'll need to be able to access
    var frequencySlider: AKPropertySlider?
    var carrierMultiplierSlider: AKPropertySlider?
    var modulatingMultiplierSlider: AKPropertySlider?
    var modulationIndexSlider: AKPropertySlider?
    var amplitudeSlider: AKPropertySlider?
    var rampTimeSlider: AKPropertySlider?



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
            default: break
            }
            self.frequencySlider?.value            = oscillator.baseFrequency
            self.carrierMultiplierSlider?.value    = oscillator.carrierMultiplier
            self.modulatingMultiplierSlider?.value = oscillator.modulatingMultiplier
            self.modulationIndexSlider?.value      = oscillator.modulationIndex
            self.amplitudeSlider?.value            = oscillator.amplitude
            self.rampTimeSlider?.value             = oscillator.rampTime
            }
        )

        addSubview(AKButton(title: "Randomize") {
            oscillator.baseFrequency = self.frequencySlider!.randomize()
            oscillator.carrierMultiplier = self.carrierMultiplierSlider!.randomize()
            oscillator.modulatingMultiplier = self.modulatingMultiplierSlider!.randomize()
            oscillator.modulationIndex = self.modulationIndexSlider!.randomize()
        })

        frequencySlider = AKPropertySlider(
            property: "Frequency",
            format: "%0.2f Hz",
            value: oscillator.baseFrequency, maximum: 800,
            color: AKColor.yellowColor()
        ) { frequency in
            oscillator.baseFrequency = frequency
        }
        addSubview(frequencySlider!)

        carrierMultiplierSlider = AKPropertySlider(
            property: "Carrier Multiplier",
            format: "%0.3f",
            value: oscillator.carrierMultiplier, maximum: 20,
            color: AKColor.redColor()
        ) { multiplier in
            oscillator.carrierMultiplier = multiplier
        }
        addSubview(carrierMultiplierSlider!)

        modulatingMultiplierSlider = AKPropertySlider(
            property: "Modulating Multiplier",
            format: "%0.3f",
            value: oscillator.modulatingMultiplier, maximum: 20,
            color: AKColor.greenColor()
        ) { multiplier in
            oscillator.modulatingMultiplier = multiplier
        }
        addSubview(modulatingMultiplierSlider!)

        modulationIndexSlider = AKPropertySlider(
            property: "Modulation Index",
            format: "%0.3f",
            value: oscillator.modulationIndex, maximum: 100,
            color: AKColor.cyanColor()
        ) { index in
            oscillator.modulationIndex = index
        }
        addSubview(modulationIndexSlider!)


        amplitudeSlider = AKPropertySlider(
            property: "Amplitude",
            format: "%0.3f",
            value: oscillator.amplitude,
            color: AKColor.purpleColor()
        ) { amplitude in
            oscillator.amplitude = amplitude
        }
        addSubview(amplitudeSlider!)

        rampTimeSlider = AKPropertySlider(
            property: "Ramp Time",
            format: "%0.3f s",
            value: oscillator.rampTime, maximum: 10,
            color: AKColor.orangeColor()
        ) { time in
            oscillator.rampTime = time
        }
        addSubview(rampTimeSlider!)
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()