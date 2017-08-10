//: ## Oscillator Bank
import AudioKitPlaygrounds
import AudioKit

let bank = AKOscillatorBank(waveform: AKTable(.sine),
                            attackDuration: 0.1,
                            releaseDuration: 0.1)

AudioKit.output = bank
AudioKit.start()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView!

    override func setup() {
        addTitle("Oscillator Bank")

        let adsrView = AKADSRView { att, dec, sus, rel in
            bank.attackDuration = att
            bank.decayDuration = dec
            bank.sustainLevel = sus
            bank.releaseDuration = rel
        }
        adsrView.attackDuration = bank.attackDuration
        adsrView.decayDuration = bank.decayDuration
        adsrView.releaseDuration = bank.releaseDuration
        adsrView.sustainLevel = bank.sustainLevel
        addSubview(adsrView)

        addSubview(AKPropertySlider(property: "Detuning Offset",
                                    value: bank.detuningOffset,
                                    range: -1_200 ... 1_200,
                                    format: "%0.3f Hz"
        ) { offset in
            bank.detuningOffset = offset
        })

        addSubview(AKPropertySlider(property: "Detuning Multiplier",
                                    value: bank.detuningMultiplier,
                                    range: 0.5 ... 2.0,
                                    taper: log(3) / log(2)
        ) { multiplier in
            bank.detuningMultiplier = multiplier
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
        bank.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        bank.stop(noteNumber: note)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
