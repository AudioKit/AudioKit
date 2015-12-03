//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKCustomGenerator
//: ### Add description
import XCPlayground
import AudioKit

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance

let generator = AKCustomGenerator("5 1 sine 220 440 scale 0.3 sine dup")

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
