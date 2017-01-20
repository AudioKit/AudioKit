//: ## FM Oscillator Bank
//: Open the timeline view to use the controls this playground sets up.
//:

import PlaygroundSupport
import AudioKit

let fmBank = AKFMOscillatorBank()

AudioKit.output = fmBank
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView?

    override func setup() {
        addTitle("FM Oscillator Bank")

        addSubview(AKPropertySlider(
            property: "Carrier Multiplier",
            format: "%0.3f",
            value: fmBank.carrierMultiplier, maximum: 2,
            color: AKColor.red
        ) { multiplier in
            fmBank.carrierMultiplier = multiplier
            })

        addSubview(AKPropertySlider(
            property: "Modulating Multiplier",
            format: "%0.3f",
            value: fmBank.modulatingMultiplier, maximum: 2,
            color: AKColor.green
        ) { multiplier in
            fmBank.modulatingMultiplier = multiplier
            })

        addSubview(AKPropertySlider(
            property: "Modulation Index",
            format: "%0.3f",
            value: fmBank.modulationIndex, maximum: 20,
            color: AKColor.cyan
        ) { index in
            fmBank.modulationIndex = index
            })

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f",
            value: fmBank.attackDuration, maximum: 2,
            color: AKColor.green
        ) { duration in
            fmBank.attackDuration = duration
            })

        addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f",
            value: fmBank.releaseDuration, maximum: 2,
            color: AKColor.green
        ) { duration in
            fmBank.releaseDuration = duration
            })

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        addSubview(keyboard!)

        addSubview(AKButton(title: "Go Polyphonic") {
            self.keyboard?.polyphonicMode = !self.keyboard!.polyphonicMode
            if self.keyboard!.polyphonicMode {
                return "Go Monophonic"
            } else {
                return "Go Polyphonic"
            }
            })
    }

    func noteOn(note: MIDINoteNumber) {
        fmBank.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        fmBank.stop(noteNumber: note)
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
