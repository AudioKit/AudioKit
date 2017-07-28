//: ## Phase Distortion Oscillator Bank
import AudioKitPlaygrounds
import AudioKit

let osc = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square))

AudioKit.output = osc
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView!

    override func setup() {
        addTitle("Phase Distortion Oscillator Bank")

        addSubview(AKPropertySlider(property: "Phase Distortion",
                                    value: osc.phaseDistortion) { sliderValue in
            osc.phaseDistortion = sliderValue
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

        addSubview(AKPropertySlider(property: "Detuning Offset",
                                    value:  osc.releaseDuration,
                                    range: -1_200 ... 1_200,
                                    format: "%0.1f Cents"
        ) { sliderValue in
            osc.detuningOffset = sliderValue
        })

        addSubview(AKPropertySlider(property: "Detuning Multiplier",
                                    value:  osc.detuningMultiplier,
                                    range: 0.5 ... 2.0,
                                    taper: log(3) / log(2)
        ) { sliderValue in
            osc.detuningMultiplier = sliderValue
        })

        keyboard = AKKeyboardView(width: 440, height: 100)
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
