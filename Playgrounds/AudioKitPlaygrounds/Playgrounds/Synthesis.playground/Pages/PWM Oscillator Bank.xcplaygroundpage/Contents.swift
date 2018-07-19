//: ## PWM Oscillator Bank
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let bank = AKPWMOscillatorBank(pulseWidth: 0.5)

AudioKit.output = bank
try AudioKit.start()

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    var keyboard: AKKeyboardView!

    override func viewDidLoad() {
        addTitle("PWM Oscillator Bank")

        addView(AKSlider(property: "Pulse Width", value: bank.pulseWidth) { sliderValue in
            bank.pulseWidth = sliderValue
        })

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
        addView(adsrView)

        addView(AKSlider(property: "Pitch Bend",
                         value: bank.pitchBend,
                         range: -12 ... 12,
                         format: "%0.2f semitones"
        ) { sliderValue in
            bank.pitchBend = sliderValue
        })

        addView(AKSlider(property: "Vibrato Depth",
                         value: bank.vibratoDepth,
                         range: 0 ... 2,
                         format: "%0.2f semitones"
        ) { sliderValue in
            bank.vibratoDepth = sliderValue
        })

        addView(AKSlider(property: "Vibrato Rate",
                         value: bank.vibratoRate,
                         range: 0 ... 10,
                         format: "%0.2f Hz"
        ) { sliderValue in
            bank.vibratoRate = sliderValue
        })

        keyboard = AKKeyboardView(width: 440, height: 100, firstOctave: 3, octaveCount: 3)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
        addView(keyboard)

        addView(AKButton(title: "Go Polyphonic") { button in
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
PlaygroundPage.current.liveView = LiveView()
