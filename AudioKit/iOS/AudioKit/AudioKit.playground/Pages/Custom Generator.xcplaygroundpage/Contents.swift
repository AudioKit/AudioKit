//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Custom Generator
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: ```AKP``` is basically shorthand for AKParameter, with type methods that return AKParameters that you can use in other operations
let slowSine = round(AKParameter.sine(preset: .Slow)  * 12) / 12
let vibrato  = slowSine.scaledTo(minimum: -1200, maximum: 1200)

let fastSine = AKParameter.sine(preset: .Fast)
let volume   = fastSine.scaledTo(minimum: 0, maximum: 0.5)

let leftOutput  = sine(frequency: 440 + vibrato, amplitude: volume)
let rightOutput = sine(frequency: 220 + vibrato, amplitude: volume)

let generator = AKNode.generator(leftOutput, rightOutput)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
