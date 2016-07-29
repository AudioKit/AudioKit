//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Oscillator Synth
//:
import XCPlayground
import AudioKit

//: Choose the waveform shape here

let waveform = AKTable(.Sawtooth) // .Triangle, etc.

var oscillator = AKOscillator(waveform: waveform)

var currentAmplitude = 0.1
var currentRampTime = 0.0

AudioKit.output = oscillator
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {
    
    override func setup() {
        addTitle("Oscillator Synth")
        
        addSubview(AKPropertySlider(
            property: "Amplitude",
            format: "%0.3f",
            value: oscillator.amplitude,
            color: AKColor.purpleColor()
        ) { amplitude in
            currentAmplitude = amplitude
            })
        
        addSubview(AKPropertySlider(
            property: "Ramp Time",
            format: "%0.3f s",
            value: oscillator.rampTime, maximum: 1,
            color: AKColor.orangeColor()
        ) { time in
            currentRampTime = time
            })
        
        let keyboard = AKKeyboardView(width: playgroundWidth - 60,
                                      height: 100, totalKeys: 36)
        keyboard.delegate = self
        addSubview(keyboard)
    }
    
    func noteOn(note: MIDINoteNumber) {
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
    
    func noteOff(note: MIDINoteNumber) {
        oscillator.amplitude = 0
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
