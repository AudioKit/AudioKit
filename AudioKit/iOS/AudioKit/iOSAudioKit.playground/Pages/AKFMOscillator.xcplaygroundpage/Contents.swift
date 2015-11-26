//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FM Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let fm = AKFMOscillator()
audiokit.audioOutput = fm
audiokit.start()

while true {
    fm.baseFrequency        = Float(arc4random_uniform(400)) + 400
    fm.carrierMultiplier    = Float(arc4random_uniform(4))
    fm.modulationIndex      = Float(arc4random_uniform(5))
    fm.modulatingMultiplier = Float(arc4random_uniform(10)) * 0.03
    fm.amplitude            = Float(arc4random_uniform(10)) * 0.03
    usleep(80000)
}
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
