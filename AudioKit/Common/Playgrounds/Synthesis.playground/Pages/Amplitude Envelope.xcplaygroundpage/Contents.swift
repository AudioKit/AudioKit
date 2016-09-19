//: ## Amplitude Envelope
//: Enveloping an Oscillator with an ADSR envelope
import PlaygroundSupport
import AudioKit

var fmWithADSR = AKOscillatorBank()
AudioKit.output = AKBooster(fmWithADSR, gain: 5)
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var holdDuration = 1.0

    override func setup() {

        addTitle("ADSR Envelope")

        let adsrView = AKADSRView() {
            att, dec, sus, rel in
            fmWithADSR.attackDuration = att
            fmWithADSR.decayDuration = dec
            fmWithADSR.sustainLevel = sus
            fmWithADSR.releaseDuration = rel
            Swift.print("fmWithADSR.attackDuration  = \(att)")
            Swift.print("fmWithADSR.decayDuration   = \(dec)")
            Swift.print("fmWithADSR.sustainLevel    = \(sus)")
            Swift.print("fmWithADSR.releaseDuration = \(rel)\n")
        }
        adsrView.attackDuration  = fmWithADSR.attackDuration
        adsrView.decayDuration   = fmWithADSR.decayDuration
        adsrView.releaseDuration = fmWithADSR.releaseDuration
        adsrView.sustainLevel    = fmWithADSR.sustainLevel
        addSubview(adsrView)

        let plot = AKRollingOutputPlot.createView(width: 440, height: 330)
        addSubview(plot)

        let keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
        addSubview(keyboard)

    }

    func noteOn(noteNumber: MIDINoteNumber) {
        fmWithADSR.play(noteNumber: noteNumber, velocity: 80)
    }

    func noteOff(noteNumber: MIDINoteNumber) {
        fmWithADSR.stop(noteNumber: noteNumber)
    }

}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
