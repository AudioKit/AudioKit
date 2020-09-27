//: ## Flute
//: Physical model of a Flute

import AudioKit

let playRate = 2.0

let flute = Flute()

let reverb = Reverb(flute)

let scale = [0, 2, 4, 5, 7, 9, 11, 12]

let performance = PeriodicFunction(frequency: playRate) {
    var note = scale.randomElement()!
    let octave = (2..<6).randomElement()! * 12
    if AUValue.random(in: 0...10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { Log("ACCIDENT!") }

    let frequency = (note + octave).midiNoteToFrequency()
    if AUValue.random(in: 0...6) > 1.0 {
        flute.trigger(frequency: frequency, amplitude: 0.1)
    } else {
        flute.stop()
    }
}

engine.output = reverb
try engine.start(withPeriodicFunctions: performance)
performance.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
