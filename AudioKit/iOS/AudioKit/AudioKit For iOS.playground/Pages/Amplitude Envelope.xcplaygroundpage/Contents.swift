//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Amplitude Envelope
//: ### Enveloping an FM Oscillator with an ADSR envelope
import PlaygroundSupport
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
    
    var attackLabel: Label?
    var decayLabel: Label?
    var sustainLabel: Label?
    var releaseLabel: Label?
    var durationLabel: Label?
    var attackSlider: Slider?
    var decaySlider: Slider?
    var sustainSlider: Slider?
    var releaseSlider: Slider?
    var durationSlider: Slider?

    override func setup() {
        let plotView = AKRollingOutputPlot.createView(500, height: 560)
        self.addSubview(plotView)

        addTitle("ADSR Envelope")

        attackLabel = addLabel("Attack Duration: \(fmWithADSR.attackDuration)")
        attackSlider = addSlider(#selector(setAttack), value: fmWithADSR.attackDuration)

        decayLabel = addLabel("Decay Duration: \(fmWithADSR.decayDuration)")
        decaySlider = addSlider(#selector(setDecay), value: fmWithADSR.decayDuration)

        sustainLabel = addLabel("Sustain Label: \(fmWithADSR.sustainLevel)")
        sustainSlider = addSlider(#selector(setSustain), value: fmWithADSR.sustainLevel)

        releaseLabel = addLabel("Release Duration: \(fmWithADSR.releaseDuration)")
        releaseSlider = addSlider(#selector(setRelease), value: fmWithADSR.releaseDuration)
        
        durationLabel = addLabel("Hold Duration: \(holdDuration)")
        durationSlider = addSlider(#selector(setDuration),
                                   value: 1.0,
                                   minimum: 0.0,
                                   maximum: 5.0)

        addButton("Play Current", action: #selector(PlaygroundView.play))
        addButton("Randomize", action: #selector(randomize))
        

    }
    
    func setAttack(slider: Slider) {
        fmWithADSR.attackDuration = Double(slider.value)
        attackLabel!.text = "Attack Duration: \(fmWithADSR.attackDuration)"
    }

    func setDecay(slider: Slider) {
        fmWithADSR.decayDuration = Double(slider.value)
        decayLabel!.text = "Decay Duration: \(fmWithADSR.decayDuration)"
    }

    func setSustain(slider: Slider) {
        fmWithADSR.sustainLevel = Double(slider.value)
        sustainLabel!.text = "Sustain Label: \(fmWithADSR.sustainLevel)"
    }

    func setRelease(slider: Slider) {
        fmWithADSR.releaseDuration = Double(slider.value)
        releaseLabel!.text = "Release Duration: \(fmWithADSR.releaseDuration)"
    }
    
    func setDuration(slider: Slider) {
        holdDuration = Double(slider.value)
        durationLabel!.text = "Hold Duration: \(holdDuration)"
    }

    func play() {
        fmOscillator.baseFrequency = random(220, 880)
        fmWithADSR.start()
        self.performSelector(#selector(stop), withObject: nil, afterDelay: holdDuration)
    }
    
    func stop() {
        fmWithADSR.stop()
    }
    
    func randomize() {
        fmWithADSR.attackDuration  = random(0.01, 0.5)
        fmWithADSR.decayDuration   = random(0.01, 0.2)
        fmWithADSR.sustainLevel    = random(0.01, 1)
        fmWithADSR.releaseDuration = random(0.01, 1)
        holdDuration = fmWithADSR.attackDuration + fmWithADSR.decayDuration + 0.5

        
        attackSlider!.value = Float(fmWithADSR.attackDuration)
        attackLabel!.text = "Attack Duration: \(fmWithADSR.attackDuration)"
        
        decaySlider!.value = Float(fmWithADSR.decayDuration)
        decayLabel!.text = "Decay Duration: \(fmWithADSR.decayDuration)"
        
        sustainSlider!.value = Float(fmWithADSR.sustainLevel)
        sustainLabel!.text = "Sustain Level: \(fmWithADSR.sustainLevel)"
        
        releaseSlider!.value = Float(fmWithADSR.releaseDuration)
        releaseLabel!.text = "Release Duration: \(fmWithADSR.releaseDuration)"
        
        durationSlider!.value = Float(holdDuration)
        durationLabel!.text = "Hold Duration: \(holdDuration)"

        play()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 560))
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
