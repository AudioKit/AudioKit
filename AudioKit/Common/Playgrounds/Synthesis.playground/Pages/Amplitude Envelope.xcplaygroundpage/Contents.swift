//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Amplitude Envelope
//: ### Enveloping an FM Oscillator with an ADSR envelope
import XCPlayground
import AudioKit

var fmWithADSR = AKFMOscillatorBank()
AudioKit.output = AKBooster(fmWithADSR, gain: 5)
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var holdDuration = 1.0

    override func setup() {

        addTitle("ADSR Envelope")
        
        let adsrView = AKADSRView(node: fmWithADSR) {
            att, dec, sus, rel in
            fmWithADSR.attackDuration = att
            fmWithADSR.decayDuration = dec
            fmWithADSR.sustainLevel = sus
            fmWithADSR.releaseDuration = rel
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

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
