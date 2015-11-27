//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## White Noise
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let noise = AKWhiteNoise()
noise.amplitude = 0.0
audiokit.audioOutput = noise
audiokit.start()

var t: Float = 0
while true {
    noise.amplitude = (1.0 - cos(t)) / 4.0
    t = t + 0.01
    usleep(1000000 / 100)
}

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
