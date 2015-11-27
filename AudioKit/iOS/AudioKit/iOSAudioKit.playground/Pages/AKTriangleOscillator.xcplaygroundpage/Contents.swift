//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Triangle Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let sawtooth = AKTriangleOscillator()
audiokit.audioOutput = sawtooth
audiokit.start()

while true {
    sawtooth.frequency.randomize(200, 600)
    sawtooth.amplitude.randomize(0, 0.3)
    usleep(120000)
}
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
