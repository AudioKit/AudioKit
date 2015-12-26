//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Another Example of Using Functions
//: ### You can encapsualate functionality of operations into functions.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

func instrument(noteNumber: Int, rate: Double, amplitude: Double) -> AKOperation {
    let metro = metronome(82.0 / (60.0 * rate))
    let frequency = noteNumber.midiNoteToFrequency()
    return AKOperation.fmOscillator(baseFrequency: frequency, amplitude: amplitude)
        .triggeredBy(metro, attack: 0.5, hold: 1, release: 1)
}

let instrument1 = instrument(60, rate: 4, amplitude: 0.5)
let instrument2 = instrument(62, rate: 5, amplitude: 0.4)
let instrument3 = instrument(65, rate: 7, amplitude: 1.3/4.0)
let instrument4 = instrument(67, rate: 7, amplitude: 0.125)

let instruments = (instrument1 + instrument2 + instrument3 + instrument4) * 0.13

let reverb = instruments.reverberatedWithCostello(feedback: 0.9, cutoffFrequency: 10000).toMono()

let generator = AKOperationGenerator(operation: mix(instruments, reverb, t: 0.4))

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
