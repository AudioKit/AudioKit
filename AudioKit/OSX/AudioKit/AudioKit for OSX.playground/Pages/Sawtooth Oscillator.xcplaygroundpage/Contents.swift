//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sawtooth Oscillator
//: 
import XCPlayground
import AudioKit

var sawtooth = AKSawtoothOscillator()
AudioKit.output = sawtooth
AudioKit.start()

sawtooth.start()

AKPlaygroundLoop(every: 0.12) {
    sawtooth.amplitude = random(0, 0.3)
    
    let scale = [0, 2, 4, 5, 7, 9, 11, 12]
    var note = scale.randomElement()
    let octave = randomInt(3...6)  * 12
    sawtooth.frequency = (note + octave).midiNoteToFrequency()
    sawtooth.amplitude = random(0, 0.3)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
