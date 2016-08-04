//: ## Stereo Operation
//: ### This is an example of building a stereo sound generator.
import XCPlayground
import AudioKit

let generator = AKOperationGenerator(numberOfChannels: 2) { _ in

    let slowSine = round(AKOperation.sineWave(frequency: 1)  * 12) / 12
    let vibrato  = slowSine.scale(minimum: -1200, maximum: 1200)

    let fastSine = AKOperation.sineWave(frequency: 10)
    let volume   = fastSine.scale(minimum: 0, maximum: 0.5)

    let leftOutput  = AKOperation.sineWave(frequency: 440 + vibrato,
                                           amplitude: volume)
    let rightOutput = AKOperation.sineWave(frequency: 220 + vibrato,
                                           amplitude: volume)

    return [leftOutput, rightOutput]
}

AudioKit.output = generator
AudioKit.start()
generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
