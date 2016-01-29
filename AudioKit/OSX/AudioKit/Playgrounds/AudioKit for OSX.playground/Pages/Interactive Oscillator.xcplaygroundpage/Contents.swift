//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import UIKit
import XCPlayground
import AudioKit

class ViewController: AKPlaygroundViewController {
    
//: Create an instance of AudioKit and an oscillator
    let audiokit = AKManager.sharedInstance
    var oscillator = AKOscillator()
    
//: UI Elements we'll need to be able to access
    var frequencyLabel: UILabel?
    var amplitudeLabel: UILabel?
    

    override func viewDidLoad() {
        super.viewDidLoad()

//: Set up AudioKit's audio graph
        audiokit.audioOutput = oscillator
        audiokit.start()

//: Starting values
        oscillator.amplitude = 0.1
        
//: Create the UI
        addTitle("AKOscillator")
        addSwitch("toggle:")
        frequencyLabel = addLabel("Frequency: 440")
        addSlider("setFrequency:", value: 440, minimum: 200, maximum: 800)
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
    
    func setFrequency(slider: UISlider) {
        oscillator.frequency = Double(slider.value)
        let frequency = String(format: "%0.1f", oscillator.frequency)
        frequencyLabel!.text = "Frequency: \(frequency)"
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
