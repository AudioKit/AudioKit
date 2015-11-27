//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let triangle = AKTable.standardTriangleWave()
for value in triangle.values { value } // Click the eye icon ->

let square = AKTable.standardSquareWave()
for value in square.values { value } // Click the eye icon ->

let sine = AKTable.standardSineWave()
for value in sine.values { value } // Click the eye icon ->

let sawtooth = AKTable.standardSawtoothWave()
for value in sawtooth.values { value } // Click the eye icon ->

//: Try changing the table to triangle, square, sine, or sawtooth
let oscillator = AKOscillator(table: sine)
audiokit.audioOutput = oscillator
audiokit.start()

while true {
    oscillator.frequency.randomize(220,440)
    oscillator.amplitude.randomize(0, 0.5)
    usleep(200000)
}
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
