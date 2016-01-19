//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Square Wave Oscillator
//: 
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
var square = AKSquareWaveOscillator()
audiokit.audioOutput = square
audiokit.start()

square.start()

var t: Double = 0

AKPlaygroundLoop(every: 0.12) {
    square.pulseWidth = 0.75 -  0.24 * cos(10*t)
    square.pulseWidth
    t = t + 0.01
    
    let scale = [0,2,4,5,7,9,11,12]
    var note = scale.randomElement()
    let octave = randomInt(3...6)  * 12
    square.frequency = (note + octave).midiNoteToFrequency()
    square.amplitude = random(0, 0.3)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
