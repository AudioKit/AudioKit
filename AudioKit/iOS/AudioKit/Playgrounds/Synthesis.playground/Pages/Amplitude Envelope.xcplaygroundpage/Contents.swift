//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Amplitude Envelope
//: ### Enveloping an FM Oscillator with an ADSR envelope
import XCPlayground
import AudioKit


var fmOscillator = AKFMOscillator()
var fmWithADSR = AKAmplitudeEnvelope(fmOscillator,
                                     attackDuration: 0.1,
                                     decayDuration: 0.1,
                                     sustainLevel: 0.8,
                                     releaseDuration: 0.1)

AudioKit.output = fmWithADSR
AudioKit.start()

fmOscillator.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var holdDuration = 1.0

    override func setup() {

        addTitle("ADSR Envelope")
        
        addButton("Play Current", action: #selector(PlaygroundView.play))
//        addButton("Randomize", action: #selector(randomize))

        
        addSubview(AKPropertySlider(
            property: "Attack",
            format: "%0.3f s",
            value: fmWithADSR.attackDuration, maximum: 2,
            color: AKColor.greenColor()
        ) { duration in
            fmWithADSR.attackDuration = duration
            })
        addSubview(AKPropertySlider(
            property: "Decay",
            format: "%0.3f s",
            value: fmWithADSR.decayDuration, maximum: 2,
            color: AKColor.cyanColor()
        ) { duration in
            fmWithADSR.decayDuration = duration
            })
        
        addSubview(AKPropertySlider(
            property: "Sustain Level",
            value: fmWithADSR.sustainLevel,
            color: AKColor.yellowColor()
        ) { level in
            fmWithADSR.sustainLevel = level
            })
        addSubview(AKPropertySlider(
            property: "Release",
            format: "%0.3f s",
            value: fmWithADSR.releaseDuration, maximum: 2,
            color: AKColor.greenColor()
        ) { duration in
            fmWithADSR.releaseDuration = duration
            })
        
        addSubview(AKPropertySlider(
            property: "Duration",
            format: "%0.3f s",
            value: holdDuration, maximum: 5,
            color: AKColor.greenColor()
        ) { duration in
            self.holdDuration = duration
            })

        addSubview(AKRollingOutputPlot.createView(width: 440, height: 330))

    }
    
    func play() {
        fmOscillator.baseFrequency = random(220, 880)
        fmWithADSR.start()
        self.performSelector(#selector(stop), withObject: nil, afterDelay: holdDuration)
    }

    func stop() {
        fmWithADSR.stop()
    }

//    func randomize() {
//        fmWithADSR.attackDuration = random(0.01, 0.5)
//        fmWithADSR.decayDuration = random(0.01, 0.2)
//        fmWithADSR.sustainLevel = random(0.01, 1)
//        fmWithADSR.releaseDuration = random(0.01, 1)
//        holdDuration = fmWithADSR.attackDuration + fmWithADSR.decayDuration + 0.5
//
//        play()
//    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 920))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
