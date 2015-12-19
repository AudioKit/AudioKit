//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Using Functions
//: ### You can encapsualate functionality of operations into functions.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

func drone(frequency: Double, rate: Double) -> AKOperation {
    let metro = metronome(rate)
    let tone = sineWave(frequency: frequency.ak, amplitude: 0.2.ak)
    return tone.triggeredBy(metro, attack: 0.01.ak, hold: 0.1.ak, release: 0.1.ak)
}

let drone1 = drone(440, rate: 3)
let drone2 = drone(330, rate: 5)
let drone3 = drone(450, rate: 7)

let generator = AKNode.generator((drone1 + drone2 + drone3) / 3)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
