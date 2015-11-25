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
oscillator.frequency = 0
print(oscillator.output)
audiokit.audioOutput = oscillator
audiokit.start()

while true {
    let nowDouble = NSDate().timeIntervalSince1970
    oscillator.frequency = abs(Float(sin(nowDouble*10))) * 400  + 400
    usleep(80000)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
