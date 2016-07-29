//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phase Distortion Oscillator
//:
import XCPlayground
import AudioKit

var oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.Sawtooth))
oscillator.phaseDistortion = 0.0
var currentAmplitude = 0.1
var currentRampTime = 0.0

AudioKit.output = oscillator
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var frequencyLabel: Label?
    var pulseWidthLabel: Label?
    var amplitudeLabel: Label?
    var rampTimeLabel: Label?

    override func setup() {
        addTitle("Phase Distortion Oscillator")

        
        amplitudeLabel = addLabel("Amplitude: \(currentAmplitude)")
        addSlider(#selector(setAmplitude), value: currentAmplitude)

        pulseWidthLabel = addLabel("Phase Distortion: \(oscillator.phaseDistortion)")
        addSlider(#selector(setPhaseDistortion),
                  value: oscillator.phaseDistortion,
                  minimum: -1,
                  maximum: 1)

        rampTimeLabel = addLabel("Ramp Time: \(currentRampTime)")
        addSlider(#selector(setRampTime), value: currentRampTime, minimum: 0, maximum: 5.0)

        let keyboard = AKKeyboardView(width: playgroundWidth, height: 100)
        keyboard.delegate = self

        keyboard.frame.origin.y = 200
        self.addSubview(keyboard)
    }

    func noteOn(note: Int) {
        // start from the correct note if amplitude is zero
        if oscillator.amplitude == 0 {
            oscillator.rampTime = 0
        }
        oscillator.frequency = note.midiNoteToFrequency()

        // Still use rampTime for volume
        oscillator.rampTime = currentRampTime
        oscillator.amplitude = currentAmplitude
        oscillator.play()
    }

    func noteOff(note: Int) {
        oscillator.amplitude = 0
    }

    func setPhaseDistortion(slider: Slider) {
        oscillator.phaseDistortion = Double(slider.value)
        let pd = String(format: "%0.3f", oscillator.phaseDistortion)
        pulseWidthLabel!.text = "Phase Distortion: \(pd)"
    }


    func setAmplitude(slider: Slider) {
        currentAmplitude = Double(slider.value)
        let amp = String(format: "%0.3f", currentAmplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
    }

    func setRampTime(slider: Slider) {
        currentRampTime = Double(slider.value)
        let rampTime = String(format: "%0.3f", currentRampTime)
        rampTimeLabel!.text = "Ramp Time: \(rampTime)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
