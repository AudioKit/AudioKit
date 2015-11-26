//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let oscillator = AKOscillator()
oscillator.amplitude = 0.3
audiokit.audioOutput = oscillator
audiokit.start()

while true {
    oscillator.frequency.randomize(0,400)
    oscillator.amplitude.randomize(0, 0.5)
    usleep(200000)
}
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
