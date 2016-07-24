//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Using Functions
//: ### You can encapsualate functionality of operations into functions.
import XCPlayground
import AudioKit

func drone(frequency: Double, rate: Double) -> AKOperation {
    let metro = AKOperation.metronome(frequency: rate)
    let tone = AKOperation.sineWave(frequency: frequency, amplitude: 0.2)
    return tone.triggeredWithEnvelope(trigger: metro, attack: 0.01, hold: 0.1, release: 0.1)
}

let generator = AKOperationGenerator() { _ in
    
    let drone1 = drone(440, rate: 3)
    let drone2 = drone(330, rate: 5)
    let drone3 = drone(450, rate: 7)
    
    return (drone1 + drone2 + drone3) / 3
}

AudioKit.output = generator
AudioKit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
