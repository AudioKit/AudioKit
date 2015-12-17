//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Custom Generator
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let slowSine = round(sineWave(frequency: 1.ak)  * 12) / 12
let vibrato  = slowSine.scaledTo(minimum: -1200, maximum: 1200)

let fastSine = sineWave(frequency: 10.ak)
let volume   = fastSine.scaledTo(minimum: 0, maximum: 0.5)

let leftOutput  = sineWave(frequency: 440 + vibrato, amplitude: volume)
let rightOutput = sineWave(frequency: 220 + vibrato, amplitude: volume)

let generator = AKNode.generator(leftOutput, rightOutput)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
