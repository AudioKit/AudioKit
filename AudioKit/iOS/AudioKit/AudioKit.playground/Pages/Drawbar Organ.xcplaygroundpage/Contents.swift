//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive Drawbar Organ
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator1 = AKOscillator()
oscillator1.amplitude = 0.1
var oscillator2 = AKOscillator()
oscillator2.amplitude = 0.1
var oscillator3 = AKOscillator()
oscillator3.amplitude = 0.1
var oscillator4 = AKOscillator()
oscillator4.amplitude = 0.1
var oscillator5 = AKOscillator()
oscillator5.amplitude = 0.1
var oscillator6 = AKOscillator()
oscillator6.amplitude = 0.1
var oscillator7 = AKOscillator()
oscillator7.amplitude = 0.1
var oscillator8 = AKOscillator()
oscillator8.amplitude = 0.1
var oscillator9 = AKOscillator()
oscillator9.amplitude = 0.1


let mixer = AKMixer(oscillator1, oscillator2, oscillator3, oscillator4, oscillator5, oscillator6, oscillator7, oscillator8, oscillator9)
AudioKit.output = mixer
AudioKit.start()
oscillator1.play()
oscillator2.play()
oscillator3.play()
oscillator4.play()
oscillator5.play()
oscillator6.play()
oscillator7.play()
oscillator8.play()
oscillator9.play()

class PlaygroundView: AKPlaygroundView {
    
    var frequencyLabel: Label?
    var amplitudeLabel1: Label?
    var amplitudeLabel2: Label?
    var amplitudeLabel3: Label?
    var amplitudeLabel4: Label?
    var amplitudeLabel5: Label?
    var amplitudeLabel6: Label?
    var amplitudeLabel7: Label?
    var amplitudeLabel8: Label?
    var amplitudeLabel9: Label?
    
    override func setup() {
        addTitle("Drawbar Organ")
        
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        frequencyLabel = addLabel("Midi Note: 440")
        addSlider(#selector(setFrequency), value: 60, minimum:0 , maximum: 127)
        amplitudeLabel1 = addLabel("Amplitude 16: 0.1")
        addSlider(#selector(setAmplitude1), value: 0.1)
        amplitudeLabel2 = addLabel("Amplitude 5 1/3: 0.1")
        addSlider(#selector(setAmplitude2), value: 0.1)
        amplitudeLabel3 = addLabel("Amplitude 8: 0.1")
        addSlider(#selector(setAmplitude3), value: 0.1)
        amplitudeLabel4 = addLabel("Amplitude 4: 0.1")
        addSlider(#selector(setAmplitude4), value: 0.1)
        amplitudeLabel5 = addLabel("Amplitude 2 2/3: 0.1")
        addSlider(#selector(setAmplitude5), value: 0.1)
        amplitudeLabel6 = addLabel("Amplitude 2: 0.1")
        addSlider(#selector(setAmplitude6), value: 0.1)
        amplitudeLabel7 = addLabel("Amplitude 1 3/5: 0.1")
        addSlider(#selector(setAmplitude7), value: 0.1)
        amplitudeLabel8 = addLabel("Amplitude 1 1/3: 0.1")
        addSlider(#selector(setAmplitude8), value: 0.1)
        amplitudeLabel9 = addLabel("Amplitude 1: 0.1")
        addSlider(#selector(setAmplitude9), value: 0.1)
    }
    
    func start() {
        oscillator1.play()
        oscillator2.play()
        oscillator3.play()
        oscillator4.play()
        oscillator5.play()
        oscillator6.play()
        oscillator7.play()
        oscillator8.play()
        oscillator9.play()
    }
    func stop() {
        oscillator1.stop()
        oscillator2.stop()
        oscillator3.stop()
        oscillator4.stop()
        oscillator5.stop()
        oscillator6.stop()
        oscillator7.stop()
        oscillator8.stop()
        oscillator9.stop()
    }
    
    func setFrequency(slider: Slider) {
        oscillator1.frequency = (Double(slider.value)-12).midiNoteToFrequency()
        oscillator2.frequency = (Double(slider.value)+7).midiNoteToFrequency()
        oscillator3.frequency = (Double(slider.value)).midiNoteToFrequency()
        let frequency = String(format: "%0.1f", oscillator3.frequency)
        frequencyLabel!.text = "Midi Note: \(frequency)"
        oscillator4.frequency = (Double(slider.value)+12).midiNoteToFrequency()
        oscillator5.frequency = (Double(slider.value)+19).midiNoteToFrequency()
        oscillator6.frequency = (Double(slider.value)+24).midiNoteToFrequency()
        oscillator7.frequency = (Double(slider.value)+28).midiNoteToFrequency()
        oscillator8.frequency = (Double(slider.value)+31).midiNoteToFrequency()
        oscillator9.frequency = (Double(slider.value)+36).midiNoteToFrequency()
    }
    
    func setAmplitude1(slider: Slider) {
        oscillator1.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator1.amplitude)
        amplitudeLabel1!.text = "Amplitude 16: \(amp)"
    }
    func setAmplitude2(slider: Slider) {
        oscillator2.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator2.amplitude)
        amplitudeLabel2!.text = "Amplitude 5 1/3: \(amp)"
    }
    func setAmplitude3(slider: Slider) {
        oscillator3.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator3.amplitude)
        amplitudeLabel3!.text = "Amplitude 8: \(amp)"
    }
    func setAmplitude4(slider: Slider) {
        oscillator4.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator4.amplitude)
        amplitudeLabel4!.text = "Amplitude 4: \(amp)"
    }
    func setAmplitude5(slider: Slider) {
        oscillator5.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator5.amplitude)
        amplitudeLabel5!.text = "Amplitude 2 2/3: \(amp)"
    }
    func setAmplitude6(slider: Slider) {
        oscillator6.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator6.amplitude)
        amplitudeLabel6!.text = "Amplitude 2: \(amp)"
    }
    func setAmplitude7(slider: Slider) {
        oscillator7.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator7.amplitude)
        amplitudeLabel7!.text = "Amplitude 1 3/5: \(amp)"
    }
    func setAmplitude8(slider: Slider) {
        oscillator8.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator8.amplitude)
        amplitudeLabel8!.text = "Amplitude 1 1/3: \(amp)"
    }
    func setAmplitude9(slider: Slider) {
        oscillator9.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator9.amplitude)
        amplitudeLabel9!.text = "Amplitude 1: \(amp)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
