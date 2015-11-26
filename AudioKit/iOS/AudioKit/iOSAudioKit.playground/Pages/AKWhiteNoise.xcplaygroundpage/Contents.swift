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
noise.amplitude = 0.3
audiokit.audioOutput = noise
audiokit.start()

var t: Float = 0
while true {
    noise.amplitude = abs(sin(t)) * 0.1
    t = t + 0.01
    usleep(1000000 / 100)
}

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
