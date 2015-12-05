//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phasor
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let phasor = AKPhasor()
audiokit.audioOutput = phasor
audiokit.start()

while true {
    phasor.frequency.randomize(220, 440)
    usleep(120000)
}
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
