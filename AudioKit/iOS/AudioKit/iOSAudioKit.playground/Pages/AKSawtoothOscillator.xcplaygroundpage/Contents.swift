//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sawtooth Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let sawtooth = AKSawtoothOscillator()
audiokit.audioOutput = sawtooth
audiokit.start()

while true {
    sawtooth.frequency = Float(arc4random_uniform(200)) + 200
    sawtooth.amplitude = Float(arc4random_uniform(100)) / 400.0
    usleep(120000)
}
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
