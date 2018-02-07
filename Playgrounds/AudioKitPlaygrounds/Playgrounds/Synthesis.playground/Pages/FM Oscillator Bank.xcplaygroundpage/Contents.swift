//: ## FM Oscillator Bank
//: Open the timeline view to use the controls this playground sets up.
//:

import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let fmBank = AKFMOscillatorBank()

AudioKit.output = fmBank
try AudioKit.start()

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    var keyboard: AKKeyboardView!

    override func viewDidLoad() {
        addTitle("FM Oscillator Bank")

        addView(AKSlider(property: "Carrier Multiplier",
                         value: fmBank.carrierMultiplier,
                         range: 0 ... 2
        ) { multiplier in
            fmBank.carrierMultiplier = multiplier
        })

        addView(AKSlider(property: "Modulating Multiplier",
                         value: fmBank.modulatingMultiplier,
                         range: 0 ... 2
        ) { multiplier in
            fmBank.modulatingMultiplier = multiplier
        })

        addView(AKSlider(property: "Modulation Index",
                         value: fmBank.modulationIndex,
                         range: 0 ... 20
        ) { index in
            fmBank.modulationIndex = index
        })

        let adsrView = AKADSRView { att, dec, sus, rel in
            fmBank.attackDuration = att
            fmBank.decayDuration = dec
            fmBank.sustainLevel = sus
            fmBank.releaseDuration = rel
        }
        adsrView.attackDuration = fmBank.attackDuration
        adsrView.decayDuration = fmBank.decayDuration
        adsrView.releaseDuration = fmBank.releaseDuration
        adsrView.sustainLevel = fmBank.sustainLevel
        addView(adsrView)

        addView(AKSlider(property: "Pitch Bend",
                         value: fmBank.pitchBend,
                         range: -12 ... 12,
                         format: "%0.2f semitones"
        ) { sliderValue in
            fmBank.pitchBend = sliderValue
        })

        addView(AKSlider(property: "Vibrato Depth",
                         value: fmBank.vibratoDepth,
                         range: 0 ... 2,
                         format: "%0.2f semitones"
        ) { sliderValue in
            fmBank.vibratoDepth = sliderValue
        })

        addView(AKSlider(property: "Vibrato Rate",
                         value: fmBank.vibratoRate,
                         range: 0 ... 10,
                         format: "%0.2f Hz"
        ) { sliderValue in
            fmBank.vibratoRate = sliderValue
        })

        keyboard = AKKeyboardView(width: 440, height: 100)
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
        fmBank.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        fmBank.stop(noteNumber: note)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
