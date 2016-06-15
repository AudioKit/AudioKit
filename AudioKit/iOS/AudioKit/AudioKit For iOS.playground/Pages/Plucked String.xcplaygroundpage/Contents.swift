//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Plucked String
//: ### Experimenting with a physical model of a string
import AudioKit
import PlaygroundSupport

let playRate = 2.0

let pluckedString = AKPluckedString(frequency: 22050)

var delay  = AKDelay(pluckedString)
delay.time = 1.5 / playRate
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = AKReverb(delay)

AudioKit.output = reverb
AudioKit.start()
let scale = [0, 2, 4, 5, 7, 9, 11, 12]

AKPlaygroundLoop(frequency: playRate) {
    var note = scale.randomElement()
    let octave = randomInt(2...5)  * 12
    if random(0, 10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { print("ACCIDENT!") }
    
    let frequency = (note+octave).midiNoteToFrequency()
    if random(0, 6) > 1.0 {
        pluckedString.trigger(frequency: frequency)
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
