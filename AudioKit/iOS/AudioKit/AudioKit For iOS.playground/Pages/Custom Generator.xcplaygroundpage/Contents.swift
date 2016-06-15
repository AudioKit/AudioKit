//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Custom Generator
//: ### This is an example of building a sound generator from scratch
import PlaygroundSupport
import AudioKit

let slowSine = round(AKOperation.sineWave(frequency: 1)  * 12) / 12
let vibrato  = slowSine.scale(minimum: -1200, maximum: 1200)

let fastSine = AKOperation.sineWave(frequency: 10)
let volume   = fastSine.scale(minimum: 0, maximum: 0.5)

let leftOutput  = AKOperation.sineWave(frequency: 440 + vibrato, amplitude: volume)
let rightOutput = AKOperation.sineWave(frequency: 220 + vibrato, amplitude: volume)

let generator = AKOperationGenerator(left: leftOutput, right:  rightOutput)

AudioKit.output = generator
AudioKit.start()
generator.start()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
