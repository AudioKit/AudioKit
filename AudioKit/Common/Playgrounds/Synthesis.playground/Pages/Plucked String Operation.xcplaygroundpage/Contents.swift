//: ## Plucked String Operation
//: ### Experimenting with a physical model of a string
import XCPlayground
import AudioKit

let playRate = 2.0

let pluckNode = AKOperationGenerator() { parameters in
    let frequency = (AKOperation.parameters[1] + 40).midiNoteToFrequency()
    return AKOperation.pluckedString(
        trigger: AKOperation.trigger,
        frequency: frequency,
        amplitude: 0.5,
        lowestFrequency: 50)
}


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
    let octave = (0...3).randomElement() * 12
    if random(0, 10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { print("ACCIDENT!") }

    if random(0, 6) > 1.0 {
        pluckNode.parameters[1] = Double(note + octave)
        pluckNode.trigger()
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
