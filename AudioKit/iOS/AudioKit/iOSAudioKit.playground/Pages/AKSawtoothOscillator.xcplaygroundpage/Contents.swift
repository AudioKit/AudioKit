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
sawtooth.frequency = 0
audiokit.audioOutput = sawtooth
audiokit.start()

while true {
    let nowDouble = NSDate().timeIntervalSince1970
    sawtooth.frequency = abs(Float(sin(nowDouble*10))) * 200  + 200
    sawtooth.amplitude = abs(Float(sin(nowDouble*10))) * 0.5
    usleep(120000)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
