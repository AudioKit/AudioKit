//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sawtooth Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
var sawtooth = AKSawtoothOscillator()
audiokit.audioOutput = sawtooth
audiokit.start()

sawtooth.start()

AKPlaygroundLoop(every: 0.12) {
    sawtooth.amplitude = random(0, 0.3)
    
    let scale = [0,2,4,5,7,9,11,12]
    var note = scale.randomElement()
    let octave = randomInt(3...6)  * 12
    sawtooth.ramp(frequency: (note + octave).midiNoteToFrequency())
    sawtooth.ramp(amplitude: random(0, 0.3))
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
