//: ## Phase Distortion Oscillator Bank

import PlaygroundSupport
import AudioKit

let osc = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square))

AudioKit.output = osc
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView?

    override func setup() {
        addTitle("Phase Distortion Oscillator Bank")

        addSubview(AKPropertySlider(
            property: "Phase Distortion",
            value: osc.phaseDistortion,
            color: AKColor.red
        ) { amount in
            osc.phaseDistortion = amount
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
            value:  osc.releaseDuration, minimum: -1200, maximum: 1200,
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
        osc.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        osc.stop(noteNumber: note)
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
