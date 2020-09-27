//: ## Plucked String
//: Experimenting with a physical model of a string

import AudioKit

let playRate = 2.0

let pluckedString = PluckedString()

var delay = Delay(pluckedString)
delay.time = 1.5 / playRate
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = Reverb(delay)

let scale = [0, 2, 4, 5, 7, 9, 11, 12]
let performance = PeriodicFunction(frequency: playRate) {
    var note = scale.randomElement()!
    let octave = [2, 3, 4, 5].randomElement()! * 12
    if AUValue.random(in: 0...10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { Log("ACCIDENT!") }

    let frequency = (note + octave).midiNoteToFrequency()
    if AUValue.random(in: 0...6) > 1.0 {
        pluckedString.trigger(frequency: frequency)
    }
}

engine.output = reverb
try engine.start(withPeriodicFunctions: performance)
performance.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
