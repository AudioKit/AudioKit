//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let triangle = AKTable(.Triangle, size: 128)
for value in triangle.values { value } // Click the eye icon ->

let square = AKTable(.Square, size: 16)
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
var oscillator = AKOscillator(table: custom)
audiokit.audioOutput = oscillator
audiokit.start()

let updater = AKPlaygroundLoop(frequency: 5) {
    oscillator.frequency = random(220,440)
    oscillator.amplitude = random(0, 0.5)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
