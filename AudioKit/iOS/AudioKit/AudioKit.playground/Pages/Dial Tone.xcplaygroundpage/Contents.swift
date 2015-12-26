//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phone Tones
//: ### AudioKit is great for sound design. Here, we show you how to create some telephone sounds using the sineWave generator.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: A dial tone is simply two sine waves at different frequencies
let dialTone1 = sineWave(frequency: 350)
let dialTone2 = sineWave(frequency: 440)
let dialTone = mix(dialTone1, dialTone2, t: 0.5)

let generator = AKOperationGenerator(operation: dialTone)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
