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
        
//        addSubview(AKButton(title: "Trigger") {
//            fmOscillator.baseFrequency = random(220, 880)
//            fmWithADSR.start()
//            self.performSelector(#selector(self.stop), withObject: nil, afterDelay: self.holdDuration)
//            })
        
//        addSubview(AKPropertySlider(
//            property: "Duration",
//            format: "%0.3f s",
//            value: holdDuration, maximum: 5,
//            color: AKColor.greenColor()
//        ) { duration in
//            self.holdDuration = duration
//            })

        let plot = AKRollingOutputPlot.createView(width: 440, height: 330)
        addSubview(plot)
        
        let keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.polyphonicMode = false
        keyboard.delegate = self
        addSubview(keyboard)

    }
//    func stop() {
//        fmWithADSR.stop()
//    }
    
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
