//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Stereo Operation
//: This is an example of building a stereo sound generator.
import AudioKit

let generator = OperationGenerator(channelCount: 2) { _ in

    let slowSine = round(Operation.sineWave(frequency: 1) * 12) / 12
    let vibrato = slowSine.scale(minimum: -1_200, maximum: 1_200)

    let fastSine = Operation.sineWave(frequency: 10)
    let volume = fastSine.scale(minimum: 0, maximum: 0.5)

    let leftOutput = Operation.sineWave(frequency: 440 + vibrato, amplitude: volume)
    let rightOutput = Operation.sineWave(frequency: 220 + vibrato, amplitude: volume)

    return [leftOutput, rightOutput]
}

engine.output = generator
try engine.start()
generator.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
