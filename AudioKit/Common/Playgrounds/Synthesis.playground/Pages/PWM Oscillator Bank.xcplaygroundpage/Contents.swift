//: ## PWM Oscillator Bank

import AudioKit

let osc = AKPWMOscillatorBank(pulseWidth: 0.5)

AudioKit.output = osc
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView?

    override func setup() {
        addTitle("PWM Oscillator Bank")

        addSubview(AKPropertySlider(
            property: "Pulse Width",
            value: osc.pulseWidth,
            color: AKColor.red
        ) { amount in
            osc.pulseWidth = amount
        })

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f s",
            value: osc.attackDuration, maximum: 2,
            color: AKColor.green
        ) { duration in
            osc.attackDuration = duration
        })

        addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f s",
            value: osc.releaseDuration, maximum: 2,
            color: AKColor.green
        ) { duration in
            osc.releaseDuration = duration
        })

        addSubview(AKPropertySlider(
            property: "Detuning Offset",
            format: "%0.1f Cents",
            value:  osc.releaseDuration, minimum: -100, maximum: 100,
            color: AKColor.green
        ) { offset in
            osc.detuningOffset = offset
        })

        addSubview(AKPropertySlider(
            property: "Detuning Multiplier",
            value:  osc.detuningMultiplier, minimum: 0.5, maximum: 2.0,
            color: AKColor.green
        ) { multiplier in
            osc.detuningMultiplier = multiplier
        })

        keyboard = AKKeyboardView(width: 440, height: 100,
                                  firstOctave: 3, octaveCount: 3)
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        addSubview(keyboard)

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
        osc.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        osc.stop(noteNumber: note)
    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
