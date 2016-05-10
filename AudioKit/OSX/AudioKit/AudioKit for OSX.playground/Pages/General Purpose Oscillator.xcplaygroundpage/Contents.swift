//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## General Purpose Oscillator
//: ### This oscillator can be loaded with a wavetable of your own design, or with one of the defaults.
import XCPlayground
import AudioKit

let triangle = AKTable(.Triangle, size: 128)
for value in triangle.values { value } // Click the eye icon ->

let square = AKTable(.Square, size: 256)
for value in square.values { value } // Click the eye icon ->

let sine = AKTable(.Sine, size: 32)
for value in sine.values { value } // Click the eye icon ->

let sawtooth = AKTable(.Sawtooth, size: 16)
for value in sawtooth.values { value } // Click the eye icon ->

var custom = AKTable(size: 512)
for i in 0..<custom.values.count {
    custom.values[i] += Float(random(-0.3, 0.3) + Double(i)/2048.0)
}
for value in custom.values { value } // Click the eye icon ->

//: Try changing the table to triangle, square, sine, or sawtooth. This will change the shape of the oscillator's waveform.
var oscillator = AKOscillator(waveform: custom)
AudioKit.output = oscillator
AudioKit.start()

oscillator.start()

AKPlaygroundLoop(frequency: 5) {
//: Notice how we change the frequency directly but let the amplitude be ramped to its new value.  This is because abrupt changes in amplitude produces clicking sounds.  Frequency can also be ramped, but it is not as important.  Try setting the amplitude without the ramp to hear the difference.
    oscillator.frequency = randomInt(50...74).midiNoteToFrequency()
    oscillator.amplitude = random(0, 0.4)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
