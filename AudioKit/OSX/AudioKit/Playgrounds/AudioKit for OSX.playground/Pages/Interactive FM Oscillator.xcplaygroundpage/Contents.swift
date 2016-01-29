//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive FM Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import UIKit
import XCPlayground
import AudioKit

class ViewController: AKPlaygroundViewController {
    
//: Create an instance of AudioKit and an oscillator
    let audiokit = AKManager.sharedInstance
    var oscillator = AKFMOscillator()
    
//: UI Elements we'll need to be able to access
    var frequencyLabel: UILabel?
    var amplitudeLabel: UILabel?
    var carrierMultiplierLabel: UILabel?
    var modulatingMultiplierLabel: UILabel?
    var modulationIndexLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//: Set up AudioKit's audio graph
        audiokit.audioOutput = oscillator
        audiokit.start()
        
//: Starting values
        oscillator.amplitude = 0.1
        
//: Create the UI
        addTitle("AKFMOscillator")
        addSwitch("toggle:")
        
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
    
    func toggle(switch: UISwitch) {
        if oscillator.isPlaying {
            oscillator.stop()
        } else {
            oscillator.start()
        }
    }
    
    func setBaseFrequency(slider: UISlider) {
        oscillator.baseFrequency = Double(slider.value)
        let baseFrequency = String(format: "%0.1f", oscillator.baseFrequency)
        frequencyLabel!.text = "Base Frequency: \(baseFrequency)"
    }

    func setCarrierMultiplier(slider: UISlider) {
        oscillator.carrierMultiplier = Double(slider.value)
        let carrierMultiplier = String(format: "%0.3f", oscillator.carrierMultiplier)
        carrierMultiplierLabel!.text = "Carrier Multiplier: \(carrierMultiplier)"
    }
    
    
    func setModulatingMultiplier(slider: UISlider) {
        oscillator.modulatingMultiplier = Double(slider.value)
        let modulatingMultiplier = String(format: "%0.3f", oscillator.modulatingMultiplier)
        modulatingMultiplierLabel!.text = "Modulation Multiplier: \(modulatingMultiplier)"
    }

    func setModulationIndex(slider: UISlider) {
        oscillator.modulationIndex = Double(slider.value)
        let modulationIndex = String(format: "%0.3f", oscillator.modulationIndex)
        modulationIndexLabel!.text = "Modulation Index: \(modulationIndex)"
    }

    
    func setAmplitude(slider: UISlider) {
        oscillator.ramp(amplitude: Double(slider.value))
        let amp = String(format: "%0.3f", oscillator.amplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
    }
    
    
}

ViewController()

XCPlaygroundPage.currentPage.liveView = ViewController()
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
