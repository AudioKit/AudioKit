//: ## Plucked String Operation
//: Experimenting with a physical model of a string

import AudioKit

let playRate = 2.0

let pluckNode = OperationGenerator { parameters in
    let frequency = (Operation.parameters[1] + 40).midiNoteToFrequency()
    return Operation.pluckedString(
        trigger: Operation.trigger,
        frequency: frequency,
        amplitude: 0.5,
        lowestFrequency: 50)
}

var delay = Delay(pluckNode)
delay.time = 1.5 / playRate
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = Reverb(delay)

let scale = [0, 2, 4, 5, 7, 9, 11, 12]

let performance = PeriodicFunction(frequency: playRate) {
    var note = scale.randomElement()!
    let octave = [0, 1, 2, 3].randomElement()! * 12
    if random(in: 0...10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { Log("ACCIDENT!") }

    if random(in: 0...6) > 1.0 {
        pluckNode.parameters[1] = Double(note + octave)
        pluckNode.trigger()
    }
}

engine.output = reverb
try engine.start(withPeriodicFunctions: performance)
pluckNode.start()
performance.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
