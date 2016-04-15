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

        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))
        
        frequencyTextField = addTextField(#selector(self.setBaseFrequency(_:)), text: "Base Frequency", value: oscillator.baseFrequency)
        frequencySlider = addSlider(#selector(self.slideBaseFrequency(_:)), value: oscillator.baseFrequency, minimum: 0, maximum: 800)

        carrierMultiplierTextField = addTextField(#selector(self.setCarrierMultiplier(_:)), text: "Carrier Multiplier", value: oscillator.carrierMultiplier)
        carrierMultiplierSlider = addSlider(#selector(self.slideCarrierMultiplier(_:)), value: oscillator.carrierMultiplier, minimum: 0, maximum: 20)

        modulatingMultiplierTextField = addTextField(#selector(self.setModulatingMultiplier(_:)), text: "Modulating Multiplier", value: oscillator.modulatingMultiplier)
        modulatingMultiplierSlider = addSlider(#selector(self.slideModulatingMultiplier(_:)), value: oscillator.modulatingMultiplier, minimum: 0, maximum: 20)
        
        modulationIndexTextField = addTextField(#selector(self.setModulationIndex(_:)), text: "Modulation Index", value: oscillator.modulationIndex)
        modulationIndexSlider = addSlider(#selector(self.slideModulationIndex(_:)), value: oscillator.modulationIndex, minimum: 0, maximum: 100)

        amplitudeTextField = addTextField(#selector(self.setAmplitude(_:)), text: "Amplitude", value: oscillator.amplitude)
        amplitudeSlider = addSlider(#selector(self.slideAmplitude(_:)), value: oscillator.amplitude)
        
        rampTimeTextField = addTextField(#selector(self.setRampTime(_:)), text: "Ramp Time", value: oscillator.rampTime)
        rampTimeSlider = addSlider(#selector(self.slideRampTime(_:)), value: oscillator.rampTime, minimum: 0, maximum: 10)


        addButton("Stun Ray", action: #selector(self.presetStunRay))
        addButton("Wobble", action: #selector(self.presetWobble))
        addButton("Fog Horn", action: #selector(self.presetFogHorn))
        addButton("Buzzer", action: #selector(self.presetBuzzer))
        addButton("Spiral", action: #selector(self.presetSpiral))
        addLineBreak()
        addButton("Randomize", action: #selector(self.presetRandom))

    }

    //: Handle UI Events
    

    func start() {
        oscillator.play()
    }
    func stop() {
        oscillator.stop()
    }

    func setBaseFrequency(textField: UITextField) {
        if let value = Double(textField.text!) {
            oscillator.baseFrequency = value
            updateSliders()
        }
    }
    func slideBaseFrequency(slider: Slider) {
        oscillator.baseFrequency = Double(slider.value)
        updateTextFields()
    }
    
    func setCarrierMultiplier(textField: UITextField) {
        if let value = Double(textField.text!) {
            oscillator.carrierMultiplier = value
            updateSliders()
        }
    }
    func slideCarrierMultiplier(slider: Slider) {
        oscillator.carrierMultiplier = Double(slider.value)
        updateTextFields()
    }

    func setModulatingMultiplier(textField: UITextField) {
        if let value = Double(textField.text!) {
            oscillator.modulatingMultiplier = value
            updateSliders()
        }
    }
    func slideModulatingMultiplier(slider: Slider) {
        oscillator.modulatingMultiplier = Double(slider.value)
        updateTextFields()
    }

    func setModulationIndex(textField: UITextField) {
        if let value = Double(textField.text!) {
            oscillator.modulationIndex = value
            updateSliders()
        }
    }
    func slideModulationIndex(slider: Slider) {
        oscillator.modulationIndex = Double(slider.value)
        updateTextFields()
    }

    func setAmplitude(textField: UITextField) {
        if let value = Double(textField.text!) {
            oscillator.amplitude = value
            updateSliders()
        }
    }
    func slideAmplitude(slider: Slider) {
        oscillator.amplitude = Double(slider.value)
        updateTextFields()
    }
    
    func setRampTime(textField: UITextField) {
        if let value = Double(textField.text!) {
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
        oscillator.baseFrequency = random(Double(frequencySlider!.minimumValue), Double(frequencySlider!.maximumValue))
        oscillator.carrierMultiplier = random(Double(carrierMultiplierSlider!.minimumValue), Double(carrierMultiplierSlider!.maximumValue))
        
        oscillator.modulatingMultiplier = random(Double(modulatingMultiplierSlider!.minimumValue), Double(modulatingMultiplierSlider!.maximumValue))
        
        oscillator.modulationIndex = random(Double(modulationIndexSlider!.minimumValue), Double(modulationIndexSlider!.maximumValue))
        
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
        
        printCode()
    }
    
    func updateTextFields() {
        let baseFrequency = String(format: "%0.1f", oscillator.baseFrequency)
        frequencyTextField!.text = "\(baseFrequency)"
        
        let carrierMultiplier = String(format: "%0.3f", oscillator.carrierMultiplier)
        carrierMultiplierTextField!.text = "\(carrierMultiplier)"
        
        let modulatingMultiplier = String(format: "%0.3f", oscillator.modulatingMultiplier)
        modulatingMultiplierTextField!.text = "\(modulatingMultiplier)"
        
        let modulationIndex = String(format: "%0.3f", oscillator.modulationIndex)
        modulationIndexTextField!.text = "\(modulationIndex)"
        
        let amplitude = String(format: "%0.3f", oscillator.amplitude)
        amplitudeTextField!.text = "\(amplitude)"
        
        let rampTime = String(format: "%0.3f", oscillator.rampTime)
        rampTimeTextField!.text = "\(rampTime)"
        
        printCode()
    }
    
    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code
        
        print("public func presetXXXXXX() {")
        print("    baseFrequency = \(String(format: "%0.3f", oscillator.baseFrequency))")
        print("    carrierMultiplier = \(String(format: "%0.3f", oscillator.carrierMultiplier))")
        print("    modulatingMultiplier = \(String(format: "%0.3f", oscillator.modulatingMultiplier))")
        print("    modulationIndex = \(String(format: "%0.3f", oscillator.modulationIndex))")
        print("}\n")
    }
    
    func updateUI() {
        updateTextFields()
        updateSliders()
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
