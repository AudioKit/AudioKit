//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Bit Crush Operation
//:
import XCPlayground
import AudioKit


let generator = AKOperationGenerator() { _ in
    let sinusoid = AKOperation.sineWave(frequency: 1)
    let sampleRate = sinusoid.scale(minimum: 300, maximum: 900)
    let bitDepth   = sinusoid.scale(minimum:   8, maximum:   2)
    let oscillator = AKOperation.sineWave(frequency: 440)
    
    return oscillator.bitCrush(bitDepth: bitDepth, sampleRate: sampleRate)
}

AudioKit.output = generator
AudioKit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
