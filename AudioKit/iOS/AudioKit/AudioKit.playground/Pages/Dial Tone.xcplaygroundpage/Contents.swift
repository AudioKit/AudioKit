//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Dial Tone
//: ### AudioKit is great for sound design. Here, we show you how to create some telephone sounds using the sineWave generator.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: A dial tone is simply two sine waves at specific frequencies
let dialTone1 = AKOperation.sineWave(frequency: 350)
let dialTone2 = AKOperation.sineWave(frequency: 440)
let dialTone = mixer(dialTone1, dialTone2, balance: 0.5)

let generator = AKOperationGenerator(operation: dialTone * 0.3)

audiokit.audioOutput = generator
audiokit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
