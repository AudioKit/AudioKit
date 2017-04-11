//: ## Plucked String
//: Experimenting with a physical model of a string
import AudioKitPlaygrounds
import AudioKit

let playRate = 2.0

let pluckedString = AKPluckedString()

var delay = AKDelay(pluckedString)
delay.time = 1.5 / playRate
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = AKReverb(delay)
let performance = AKPeriodicFunction(frequency: playRate) {
    var note = scale.randomElement()
    let octave = [2, 3, 4, 5].randomElement() * 12
    if random(0, 10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { print("ACCIDENT!") }
    
    let frequency = (note + octave).midiNoteToFrequency()
    if random(0, 6) > 1.0 {
        pluckedString.trigger(frequency: frequency)
    }
}

AudioKit.output = reverb
AudioKit.periodicFunctions = [performance]
AudioKit.start()

let scale = [0, 2, 4, 5, 7, 9, 11, 12]
performance.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
