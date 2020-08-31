//: ## Clarinet
//: Physical model of a Clarinet
import AudioKitPlaygrounds
import AudioKit
import PlaygroundSupport

let playRate = 2.0

let clarinet = AKClarinet()

let reverb = AKReverb(clarinet)

let scale = [0, 2, 4, 5, 7, 9, 11, 12]

let performance = AKPeriodicFunction(frequency: playRate) {
    var note = scale.randomElement()!
    let octave = (2..<6).randomElement()! * 12
    if random(in: 0...10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { AKLog("ACCIDENT!") }

    let frequency = (note + octave).midiNoteToFrequency()
    if random(in: 0...6) > 1.0 {
        clarinet.trigger(frequency: frequency, amplitude: 0.1)
    } else {
        clarinet.stop()
    }
}

engine.output = reverb
try engine.start(withPeriodicFunctions: performance)
performance.start()

PlaygroundPage.current.needsIndefiniteExecution = true
