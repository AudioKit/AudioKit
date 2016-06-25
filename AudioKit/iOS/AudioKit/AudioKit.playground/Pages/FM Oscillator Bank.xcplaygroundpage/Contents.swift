import XCPlayground
import AudioKit

//let osc = InstrumentDemo()
let osc = AKFMOscillatorBank()

AudioKit.output = osc
AudioKit.start()

class PlaygroundView: AKPlaygroundView, KeyboardDelegate {
    var carrierMultiplierLabel: Label?
    var modulatingMultiplierLabel: Label?
    var modulationIndexLabel: Label?
    
    var attackLabel: Label?
    var releaseLabel: Label?
    
    override func setup() {
        addTitle("Polyphonic FM Oscillator")
        
        
        carrierMultiplierLabel = addLabel("Carrier Multiplier: \(osc.carrierMultiplier)")
        addSlider(#selector(setCarrierMultiplier), value: osc.carrierMultiplier, minimum: 0.0, maximum: 2.0)

        modulatingMultiplierLabel = addLabel("Modulating Multiplier: \(osc.modulatingMultiplier)")
        addSlider(#selector(setModulatingMultiplier), value: osc.modulatingMultiplier, minimum: 0.0, maximum: 2.0)

        modulationIndexLabel = addLabel("Modulation Index: \(osc.modulationIndex)")
        addSlider(#selector(setModulationIndex), value: osc.modulationIndex, minimum: 0.0, maximum: 20.0)

        
        attackLabel = addLabel("Attack: \(osc.attackDuration)")
        addSlider(#selector(setAttack), value: osc.attackDuration, minimum: 0.0, maximum: 2.0)
        
        releaseLabel = addLabel("Release: \(osc.releaseDuration)")
        addSlider(#selector(setRelease), value: osc.releaseDuration, minimum: 0.0, maximum: 2.0)
        
        let keyboard = PolyphonicKeyboardView(width: 500, height: 100)
        keyboard.frame.origin.y = CGFloat(yPosition)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.addSubview(keyboard)
    }
    
    func noteOn(note: Int) {
        osc.start(note: note, withVelocity: 80, onChannel: 0)
    }
    
    func noteOff(note: Int) {
        osc.stop(note: note, onChannel: 0)
    }

    func setCarrierMultiplier(slider: Slider) {
        osc.carrierMultiplier = Double(slider.value)
        carrierMultiplierLabel!.text = "Carrier Multiplier: \(String(format: "%0.3f", osc.carrierMultiplier))"
    }
    
    func setModulatingMultiplier(slider: Slider) {
        osc.modulatingMultiplier = Double(slider.value)
        modulatingMultiplierLabel!.text = "Modulating Multiplier: \(String(format: "%0.3f", osc.modulatingMultiplier))"
    }

    func setModulationIndex(slider: Slider) {
        osc.modulationIndex = Double(slider.value)
        modulationIndexLabel!.text = "Modulation Index: \(String(format: "%0.3f", osc.modulationIndex))"
    }

    func setAttack(slider: Slider) {
        osc.attackDuration = Double(slider.value)
        attackLabel!.text = "Attack: \(String(format: "%0.3f", osc.attackDuration))"
    }
    
    func setRelease(slider: Slider) {
        osc.releaseDuration = Double(slider.value)
        releaseLabel!.text = "Release: \(String(format: "%0.3f", osc.releaseDuration))"
    }

    
}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view


