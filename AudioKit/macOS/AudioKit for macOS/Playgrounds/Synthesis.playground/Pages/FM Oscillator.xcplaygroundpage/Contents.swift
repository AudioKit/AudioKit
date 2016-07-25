//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FM Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
oscillator.rampTime = 0.1
AudioKit.output = oscillator
AudioKit.start()

class PlaygroundView: AKPlaygroundView {
    
    // UI Elements we'll need to be able to access
    var frequencyTextField: TextField?
    var frequencySlider: Slider?
    var carrierMultiplierTextField: TextField?
    var carrierMultiplierSlider: Slider?
    var modulatingMultiplierTextField: TextField?
    var modulatingMultiplierSlider: Slider?
    var modulationIndexTextField: TextField?
    var modulationIndexSlider: Slider?
    var amplitudeTextField: TextField?
    var amplitudeSlider: Slider?
    var rampTimeTextField: TextField?
    var rampTimeSlider: Slider?
    
    override func setup() {
        addTitle("FM Oscillator")
        
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        frequencyTextField = addTextField(#selector(setBaseFrequency),
                                          text: "Base Frequency",
                                          value: oscillator.baseFrequency)
        frequencySlider = addSlider(#selector(slideBaseFrequency),
                                    value: oscillator.baseFrequency,
                                    minimum: 0,
                                    maximum: 800)
        
        carrierMultiplierTextField = addTextField(#selector(setCarrierMultiplier),
                                                  text: "Carrier Multiplier",
                                                  value: oscillator.carrierMultiplier)
        carrierMultiplierSlider = addSlider(#selector(slideCarrierMultiplier),
                                            value: oscillator.carrierMultiplier,
                                            minimum: 0,
                                            maximum: 20)
        
        modulatingMultiplierTextField = addTextField(#selector(setModulatingMultiplier),
                                                     text: "Modulating Multiplier",
                                                     value: oscillator.modulatingMultiplier)
        modulatingMultiplierSlider = addSlider(#selector(slideModulatingMultiplier),
                                               value: oscillator.modulatingMultiplier,
                                               minimum: 0,
                                               maximum: 20)
        
        modulationIndexTextField = addTextField(#selector(setModulationIndex),
                                                text: "Modulation Index",
                                                value: oscillator.modulationIndex)
        modulationIndexSlider = addSlider(#selector(slideModulationIndex),
                                          value: oscillator.modulationIndex,
                                          minimum: 0,
                                          maximum: 100)
        
        amplitudeTextField = addTextField(#selector(setAmplitude),
                                          text: "Amplitude",
                                          value: oscillator.amplitude)
        amplitudeSlider = addSlider(#selector(slideAmplitude), value: oscillator.amplitude)
        
        rampTimeTextField = addTextField(#selector(setRampTime),
                                         text: "Ramp Time",
                                         value: oscillator.rampTime)
        rampTimeSlider = addSlider(#selector(slideRampTime),
                                   value: oscillator.rampTime,
                                   minimum: 0,
                                   maximum: 10)
        
        
        addButton("Stun Ray", action: #selector(presetStunRay))
        addButton("Wobble", action: #selector(presetWobble))
        addButton("Fog Horn", action: #selector(presetFogHorn))
        addButton("Buzzer", action: #selector(presetBuzzer))
        addButton("Spiral", action: #selector(presetSpiral))
        addLineBreak()
        addButton("Randomize", action: #selector(presetRandom))
        
    }
    
    // Handle UI Events
    
    
    func start() {
        oscillator.play()
    }
    func stop() {
        oscillator.stop()
    }
    
    func setBaseFrequency(textField: TextField) {
        if let value = Double(textField.stringValue) {
            oscillator.baseFrequency = value
            updateSliders()
        }
    }
    
    func slideBaseFrequency(slider: Slider) {
        oscillator.baseFrequency = Double(slider.value)
        updateTextFields()
    }
    
    func setCarrierMultiplier(textField: TextField) {
        if let value = Double(textField.stringValue) {
            oscillator.carrierMultiplier = value
            updateSliders()
        }
    }
    
    func slideCarrierMultiplier(slider: Slider) {
        oscillator.carrierMultiplier = Double(slider.value)
        updateTextFields()
    }
    
    func setModulatingMultiplier(textField: TextField) {
        if let value = Double(textField.stringValue) {
            oscillator.modulatingMultiplier = value
            updateSliders()
        }
    }
    
    func slideModulatingMultiplier(slider: Slider) {
        oscillator.modulatingMultiplier = Double(slider.value)
        updateTextFields()
    }
    
    func setModulationIndex(textField: TextField) {
        if let value = Double(textField.stringValue) {
            oscillator.modulationIndex = value
            updateSliders()
        }
    }
    func slideModulationIndex(slider: Slider) {
        oscillator.modulationIndex = Double(slider.value)
        updateTextFields()
    }
    
    func setAmplitude(textField: TextField) {
        if let value = Double(textField.stringValue) {
            oscillator.amplitude = value
            updateSliders()
        }
    }
    
    func slideAmplitude(slider: Slider) {
        oscillator.amplitude = Double(slider.value)
        updateTextFields()
    }
    
    func setRampTime(textField: TextField) {
        if let value = Double(textField.stringValue) {
            oscillator.rampTime = value
            updateSliders()
        }
    }
    
    func slideRampTime(slider: Slider) {
        oscillator.rampTime = Double(slider.value)
        updateTextFields()
    }
    
    func presetStunRay() {
        oscillator.presetStunRay()
        oscillator.start()
        updateUI()
    }
    
    func presetFogHorn() {
        oscillator.presetFogHorn()
        oscillator.start()
        updateUI()
    }
    
    func presetBuzzer() {
        oscillator.presetBuzzer()
        oscillator.start()
        updateUI()
    }
    
    func presetSpiral() {
        oscillator.presetSpiral()
        oscillator.start()
        updateUI()
    }
    
    func presetWobble() {
        oscillator.presetWobble()
        oscillator.start()
        updateUI()
    }
    
    func presetRandom() {
        oscillator.baseFrequency = random(Double(frequencySlider!.minValue),
                                          Double(frequencySlider!.maxValue))
        oscillator.carrierMultiplier = random(Double(carrierMultiplierSlider!.minValue),
                                              Double(carrierMultiplierSlider!.maxValue))
        
        oscillator.modulatingMultiplier = random(Double(modulatingMultiplierSlider!.minValue),
                                                 Double(modulatingMultiplierSlider!.maxValue))
        
        oscillator.modulationIndex = random(Double(modulationIndexSlider!.minValue),
                                            Double(modulationIndexSlider!.maxValue))
        
        oscillator.start()
        updateUI()
    }
    
    func updateSliders() {
        frequencySlider?.value = Float(oscillator.baseFrequency)
        carrierMultiplierSlider?.value = Float(oscillator.carrierMultiplier)
        modulatingMultiplierSlider?.value = Float(oscillator.modulatingMultiplier)
        modulationIndexSlider?.value = Float(oscillator.modulationIndex)
        amplitudeSlider?.value = Float(oscillator.amplitude)
        rampTimeSlider?.value = Float(oscillator.rampTime)
        
    }
    
    func updateTextFields() {
        let baseFrequency = String(format: "%0.1f", oscillator.baseFrequency)
        frequencyTextField!.stringValue = "\(baseFrequency)"
        
        let carrierMultiplier = String(format: "%0.3f", oscillator.carrierMultiplier)
        carrierMultiplierTextField!.stringValue = "\(carrierMultiplier)"
        
        let modulatingMultiplier = String(format: "%0.3f", oscillator.modulatingMultiplier)
        modulatingMultiplierTextField!.stringValue = "\(modulatingMultiplier)"
        
        let modulationIndex = String(format: "%0.3f", oscillator.modulationIndex)
        modulationIndexTextField!.stringValue = "\(modulationIndex)"
        
        let amplitude = String(format: "%0.3f", oscillator.amplitude)
        amplitudeTextField!.stringValue = "\(amplitude)"
        
        let rampTime = String(format: "%0.3f", oscillator.rampTime)
        rampTimeTextField!.stringValue = "\(rampTime)"
        
    }
    

    
    func updateUI() {
        updateTextFields()
        updateSliders()
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 750))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
