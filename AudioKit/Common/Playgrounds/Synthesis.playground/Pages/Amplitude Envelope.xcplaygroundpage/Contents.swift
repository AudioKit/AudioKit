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
        //AKADSRView(node: fmWithADSR) for macOS
        let adsrView = AKADSRView(node: fmWithADSR) {
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

    func noteOn(note: MIDINoteNumber) {
        fmWithADSR.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        fmWithADSR.stop(noteNumber: note)
    }

}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
