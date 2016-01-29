//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Triangular Wave Oscillator
//:
import XCPlayground
import AudioKit

var triangle = AKTriangleOscillator()
AudioKit.output = triangle
AudioKit.start()

triangle.start()

AKPlaygroundLoop(every: 0.12) {
    let scale = [0,2,4,5,7,9,11,12]
    var note = scale.randomElement()
    let octave = randomInt(3...6)  * 12
    triangle.frequency = (note + octave).midiNoteToFrequency()
    triangle.amplitude = random(0, 0.3)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
