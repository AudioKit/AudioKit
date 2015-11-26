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
    fm.baseFrequency.randomize(220, 880)
    fm.carrierMultiplier.randomize(0, 4)
    fm.modulationIndex.randomize(0, 5)
    fm.modulatingMultiplier.randomize(0, 0.3)
    fm.amplitude.randomize(0, 0.3)
    usleep(UInt32(randomInt(0...160000)))
}
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
