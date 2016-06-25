//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive Drawbar Organ
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKPolyphonicOscillator()
AudioKit.output = oscillator
AudioKit.start()

let noteCount = 9
var amplitudes = Array<Double>(count: noteCount, repeatedValue: 0.1)
var offsets = [-12, 7, 0, 12, 19, 24, 28, 31, 36]
var names = ["16", "5 1/3", "8", "4", "2 2/3", "2", "1 3/5", "1 1/3", "1"]
var baseNote = 0

class PlaygroundView: AKPlaygroundView, KeyboardDelegate {
    
    var amplitudeLabels = [Label]()
    
    override func setup() {
        addTitle("Drawbar Organ")
        
        amplitudeLabels.append(addLabel("Amplitude 16: 0.1"))
        addSlider(#selector(setAmplitude1), value: 0.1)
        amplitudeLabels.append(addLabel("Amplitude 5 1/3: 0.1"))
        addSlider(#selector(setAmplitude2), value: 0.1)
        amplitudeLabels.append(addLabel("Amplitude 8: 0.1"))
        addSlider(#selector(setAmplitude3), value: 0.1)
        amplitudeLabels.append(addLabel("Amplitude 4: 0.1"))
        addSlider(#selector(setAmplitude4), value: 0.1)
        amplitudeLabels.append(addLabel("Amplitude 2 2/3: 0.1"))
        addSlider(#selector(setAmplitude5), value: 0.1)
        amplitudeLabels.append(addLabel("Amplitude 2: 0.1"))
        addSlider(#selector(setAmplitude6), value: 0.1)
        amplitudeLabels.append(addLabel("Amplitude 1 3/5: 0.1"))
        addSlider(#selector(setAmplitude7), value: 0.1)
        amplitudeLabels.append(addLabel("Amplitude 1 1/3: 0.1"))
        addSlider(#selector(setAmplitude8), value: 0.1)
        amplitudeLabels.append(addLabel("Amplitude 1: 0.1"))
        addSlider(#selector(setAmplitude9), value: 0.1)
        
        let keyboard = KeyboardView(width: 500, height: 100, lowestKey: 48, totalKeys: 12)
        keyboard.frame.origin.y = CGFloat(yPosition)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.addSubview(keyboard)
        
    }
    
    func noteOn(note: Int) {
        stopAll()
        baseNote = note
        startAll()
    }
    
    func noteOff(note: Int) {
        stopAll()
    }
    
    func stopAll() {
        for i in 0 ..< noteCount {
            oscillator.stop(note: baseNote + offsets[i], onChannel: 0)
        }
    }
    
    func startAll() {
        for i in 0 ..< noteCount {
            oscillator.start(note: baseNote + offsets[i], withVelocity: Int(amplitudes[i] * 127), onChannel: 0)
        }
    }
    
    func setAmplitude(index: Int, slider: Slider) {
        amplitudes[index - 1] = Double(slider.value)
        let amp = String(format: "%0.3f", amplitudes[index - 1])
        amplitudeLabels[index - 1].text = "Amplitude \(names[index - 1]): \(amp)"
    }
    
    func setAmplitude1(slider: Slider) { setAmplitude(1, slider: slider) }
    func setAmplitude2(slider: Slider) { setAmplitude(2, slider: slider) }
    func setAmplitude3(slider: Slider) { setAmplitude(3, slider: slider) }
    func setAmplitude4(slider: Slider) { setAmplitude(4, slider: slider) }
    func setAmplitude5(slider: Slider) { setAmplitude(5, slider: slider) }
    func setAmplitude6(slider: Slider) { setAmplitude(6, slider: slider) }
    func setAmplitude7(slider: Slider) { setAmplitude(7, slider: slider) }
    func setAmplitude8(slider: Slider) { setAmplitude(8, slider: slider) }
    func setAmplitude9(slider: Slider) { setAmplitude(9, slider: slider) }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
