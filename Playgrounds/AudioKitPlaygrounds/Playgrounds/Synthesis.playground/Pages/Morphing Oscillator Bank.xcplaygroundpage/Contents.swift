//: ## Morphing Oscillator Bank
import AudioKitPlaygrounds
import AudioKit

let osc = AKMorphingOscillatorBank()

AudioKit.output = osc
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView!

    override func setup() {
        addTitle("Morphing Oscillator Bank")

        addSubview(AKPropertySlider(
            property: "Morph Index",
            value: osc.index, maximum: 3,
            color: AKColor.red
        ) { sliderValue in
            osc.index = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f s",
            value: osc.attackDuration, maximum: 2,
            color: AKColor.green
        ) { sliderValue in
            osc.attackDuration = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f s",
            value: osc.releaseDuration, maximum: 2,
            color: AKColor.green
        ) { sliderValue in
            osc.releaseDuration = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Detuning Offset",
            format: "%0.1f Cents",
            value:  osc.releaseDuration, minimum: -1_200, maximum: 1_200,
            color: AKColor.green
        ) { sliderValue in
            osc.detuningOffset = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Detuning Multiplier",
            value:  osc.detuningMultiplier, minimum: 0.5, maximum: 2.0,
            color: AKColor.green
        ) { sliderValue in
            osc.detuningMultiplier = sliderValue
        })

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
        addSubview(keyboard)

        addSubview(AKDynamicButton(title: "Go Polyphonic") {
            self.keyboard.polyphonicMode = !self.keyboard.polyphonicMode
            if self.keyboard.polyphonicMode {
                return "Go Monophonic"
            } else {
                return "Go Polyphonic"
            }
        })
    }

    func noteOn(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            osc.play(noteNumber: note, velocity: 80)
        }
    }

    func noteOff(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            osc.stop(noteNumber: note)
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
