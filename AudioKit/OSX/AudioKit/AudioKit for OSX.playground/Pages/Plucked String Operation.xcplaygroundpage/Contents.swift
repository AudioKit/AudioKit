//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Plucked String Operation
//: ### Experimenting with a physical model of a string
import XCPlayground
import AudioKit

let playRate = 2.0

let frequency = (AKOperation.parameters(0) + 40).midiNoteToFrequency()
let pluck = AKOperation.pluckedString(trigger: AKOperation.trigger, frequency: frequency, amplitude: 0.5, lowestFrequency: 50)

let pluckNode = AKOperationGenerator(operation: pluck)

var delay  = AKDelay(pluckNode)
delay.time = 1.5 / playRate
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = AKReverb(delay)

AudioKit.output = reverb
AudioKit.start()
pluckNode.start()

let scale = [0, 2, 4, 5, 7, 9, 11, 12]

AKPlaygroundLoop(frequency: playRate) {
    var note = scale.randomElement()
    let octave = randomInt(0...3)  * 12
    if random(0, 10) < 1.0 { note++ }
    if !scale.contains(note % 12) { print("ACCIDENT!") }

    if random(0, 6) > 1.0 {
        pluckNode.trigger([Double(note + octave)])
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
