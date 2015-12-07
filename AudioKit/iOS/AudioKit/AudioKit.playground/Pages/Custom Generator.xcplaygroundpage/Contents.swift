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
let slowSine = AKP.sine(preset: .Slow)
let vibrato  = AKP.scale(slowSine, minimumOutput: (-10).ak, maximumOutput: 10.ak)

let fastSine = AKP.sine(preset: .Fast)
let volume   = AKP.scale(fastSine) * 0.5

let leftOutput  = AKP.sine(frequency: 440 + vibrato, amplitude: volume)
let rightOutput = AKP.sine(frequency: 220 + vibrato, amplitude: volume)

let generator = AKP.generator(leftOutput, rightOutput)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
