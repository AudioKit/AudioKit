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

        addSubview(AKPropertySlider(property: "Morph Index", value: osc.index, range: 0 ... 3) { sliderValue in
            osc.index = sliderValue
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
