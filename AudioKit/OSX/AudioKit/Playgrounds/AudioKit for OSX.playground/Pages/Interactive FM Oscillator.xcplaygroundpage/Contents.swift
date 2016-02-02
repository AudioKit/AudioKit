//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive FM Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
AudioKit.output = oscillator
AudioKit.start()
oscillator.start()

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var frequencyLabel: Label?
    var amplitudeLabel: Label?
    var carrierMultiplierLabel: Label?
    var modulatingMultiplierLabel: Label?
    var modulationIndexLabel: Label?
    
    override func setup() {
        addTitle("FM Oscillator")
        
        frequencyLabel = addLabel("Base Frequency: 440")
        addSlider("setBaseFrequency:", value: 440, minimum: 200, maximum: 800)
        
        carrierMultiplierLabel = addLabel("Carrier Multiplier: 1")
        addSlider("setCarrierMultiplier:", value: 1, minimum: 0, maximum: 20)
        
        modulatingMultiplierLabel = addLabel("Modulating Multiplier: 1")
        addSlider("setModulatingMultiplier:", value: 1, minimum: 0, maximum: 20)
        
        modulationIndexLabel = addLabel("Modulation Index: 1")
        addSlider("setModulationIndex:", value: 1, minimum: 0, maximum: 100)
        
        amplitudeLabel = addLabel("Amplitude: 0.1")
        addSlider("setAmplitude:", value: 0.1)
    }
    
    //: Handle UI Events
    
    func setBaseFrequency(slider: Slider) {
        oscillator.baseFrequency = Double(slider.floatValue)
        let baseFrequency = String(format: "%0.1f", oscillator.baseFrequency)
        frequencyLabel!.stringValue = "Base Frequency: \(baseFrequency)"
    }
    
    func setCarrierMultiplier(slider: Slider) {
        oscillator.carrierMultiplier = Double(slider.floatValue)
        let carrierMultiplier = String(format: "%0.3f", oscillator.carrierMultiplier)
        carrierMultiplierLabel!.stringValue = "Carrier Multiplier: \(carrierMultiplier)"
    }
    
    
    func setModulatingMultiplier(slider: Slider) {
        oscillator.modulatingMultiplier = Double(slider.floatValue)
        let modulatingMultiplier = String(format: "%0.3f", oscillator.modulatingMultiplier)
        modulatingMultiplierLabel!.stringValue = "Modulation Multiplier: \(modulatingMultiplier)"
    }
    
    func setModulationIndex(slider: Slider) {
        oscillator.modulationIndex = Double(slider.floatValue)
        let modulationIndex = String(format: "%0.3f", oscillator.modulationIndex)
        modulationIndexLabel!.stringValue = "Modulation Index: \(modulationIndex)"
    }
    
    
    func setAmplitude(slider: Slider) {
        oscillator.ramp(amplitude: Double(slider.floatValue))
        let amp = String(format: "%0.3f", oscillator.amplitude)
        amplitudeLabel!.stringValue = "Amplitude: \(amp)"
    }
    
    
}

let view = PlaygroundView(frame: NSRect(x: 0, y: 0, width: 500, height: 550));
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
