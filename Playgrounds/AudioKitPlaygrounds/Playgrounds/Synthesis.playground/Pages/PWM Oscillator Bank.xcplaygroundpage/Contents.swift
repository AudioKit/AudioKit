//: ## PWM Oscillator Bank
import AudioKitPlaygrounds
import AudioKit

let osc = AKPWMOscillatorBank(pulseWidth: 0.5)

AudioKit.output = osc
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView!

    override func setup() {
        addTitle("PWM Oscillator Bank")

        addSubview(AKPropertySlider(
            property: "Pulse Width",
            value: osc.pulseWidth
        ) { amount in
            osc.pulseWidth = amount
        })

        let adsrView = AKADSRView { att, dec, sus, rel in
            osc.attackDuration = att
            osc.decayDuration = dec
            osc.sustainLevel = sus
            osc.releaseDuration = rel
        }
        adsrView.attackDuration = osc.attackDuration
        adsrView.decayDuration = osc.decayDuration
        adsrView.releaseDuration = osc.releaseDuration
        adsrView.sustainLevel = osc.sustainLevel
        addSubview(adsrView)

        addSubview(AKPropertySlider(
            property: "Detuning Offset",
            format: "%0.1f Cents",
            value:  osc.releaseDuration, minimum: -100, maximum: 100
        ) { offset in
            osc.detuningOffset = offset
        })

        addSubview(AKPropertySlider(
            property: "Detuning Multiplier",
            value:  osc.detuningMultiplier, minimum: 0.5, maximum: 2.0
        ) { multiplier in
            osc.detuningMultiplier = multiplier
        })

        keyboard = AKKeyboardView(width: 440, height: 100,
                                  firstOctave: 3, octaveCount: 3)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
        addSubview(keyboard)

        addSubview(AKButton(title: "Go Polyphonic") { button in
            self.keyboard.polyphonicMode = !self.keyboard.polyphonicMode
            if self.keyboard.polyphonicMode {
                button.title = "Go Monophonic"
            } else {
                button.title = "Go Polyphonic"
            }
        })
    }

    func noteOn(note: MIDINoteNumber) {
        osc.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        osc.stop(noteNumber: note)
    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
