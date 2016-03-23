//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Triangular Wave Oscillator
//:
import XCPlayground
import AudioKit

var oscillator = AKTriangleOscillator()
var currentAmplitude = 0.5
var currentInertia = 0.0

AudioKit.output = oscillator
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, KeyboardDelegate {
    
    var frequencyLabel: Label?
    var amplitudeLabel: Label?
    var inertiaLabel: Label?
    
    override func setup() {
        addTitle("Triangular Wave Oscillator")
        
        amplitudeLabel = addLabel("Amplitude: \(currentAmplitude)")
        addSlider(#selector(self.setAmplitude(_:)), value: currentAmplitude)
        
        inertiaLabel = addLabel("Inertia: \(currentInertia)")
        addSlider(#selector(self.setInertia(_:)), value: currentInertia, minimum: 0, maximum: 0.1)
        
        let keyboard = KeyboardView(width: playgroundWidth, height: 100)
        keyboard.frame.origin.y = CGFloat(yPosition)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.addSubview(keyboard)
    }
    
    func noteOn(note: Int) {
        // start from the correct note if amplitude is zero
        if oscillator.amplitude == 0 {
            oscillator.inertia = 0
        }
        oscillator.frequency = note.midiNoteToFrequency()
        
        // Still use inertia for volume
        oscillator.inertia = currentInertia
        oscillator.amplitude = currentAmplitude
        oscillator.play()
    }
    
    func noteOff(note: Int) {
        oscillator.amplitude = 0
    }
    
    
    func setAmplitude(slider: Slider) {
        currentAmplitude = Double(slider.value)
        let amp = String(format: "%0.3f", currentAmplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
    }
    
    func setInertia(slider: Slider) {
        currentInertia = Double(slider.value)
        let inertia = String(format: "%0.3f", currentInertia)
        inertiaLabel!.text = "Inertia: \(inertia)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)