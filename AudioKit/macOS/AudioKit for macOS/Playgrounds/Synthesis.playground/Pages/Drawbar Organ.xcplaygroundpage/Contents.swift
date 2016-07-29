//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive Drawbar Organ
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKOscillatorBank()
AudioKit.output = oscillator
AudioKit.start()

let noteCount = 9
var amplitudes = Array<Double>(count: noteCount, repeatedValue: 0.1)
var offsets = [-12, 7, 0, 12, 19, 24, 28, 31, 36]
var names = ["16", "5 1/3", "8", "4", "2 2/3", "2", "1 3/5", "1 1/3", "1"]
var baseNote = 0

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var amplitudeLabels = [Label]()
    var sliders = [Slider]()
    override func setup() {
        addTitle("Drawbar Organ")
        for i in 0 ..< noteCount {
            amplitudeLabels.append(addLabel("Amplitude \(names[i]): \(amplitudes[i])"))
            amplitudeLabels[i].frame.origin.y = 800-CGFloat(i)*60
            sliders.append(addSlider(#selector(setAmplitude), value: amplitudes[i]))
            sliders[i].frame.origin.y = 780-CGFloat(i)*60

        }

        let keyboard = AKKeyboardView(width: 500,
                                      height: 100,
                                      lowestKey: 48,
                                      totalKeys: 24)
        keyboard.delegate = self
        keyboard.frame.origin.y = CGFloat(yPosition)
        addSubview(keyboard)

    }

    func noteOn(note: Int) {
        if note != baseNote {
            stopAll()
            baseNote = note
            startAll()
        }
    }

    func noteOff(note: Int) {
        stopAll()
    }

    func stopAll() {
        for i in 0 ..< noteCount {
            oscillator.stop(noteNumber: baseNote + offsets[i])
        }
    }

    func startAll() {
        for i in 0 ..< noteCount {
            oscillator.play(noteNumber: baseNote + offsets[i], velocity: Int(amplitudes[i] * 127))
        }
    }

    func setAmplitude(slider: Slider) {
        if let index = sliders.indexOf(slider) {
            amplitudes[index] = Double(slider.value)
            let amp = String(format: "%0.3f", amplitudes[index])
            amplitudeLabels[index].text = "Amplitude \(names[index]): \(amp)"
        }
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 1000))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
