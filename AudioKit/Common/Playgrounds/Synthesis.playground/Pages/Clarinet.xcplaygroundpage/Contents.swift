//: ## Clarinet
//: Physical model of a Clarinet
import AudioKit
import PlaygroundSupport

let playRate = 2.0

let clarinet = AKClarinet()

let reverb = AKReverb(clarinet)

AudioKit.output = reverb
AudioKit.start()
let scale = [0, 2, 4, 5, 7, 9, 11, 12]

AKPlaygroundLoop(frequency: playRate) {
    var note = scale.randomElement()
    let octave = (2..<6).randomElement() * 12
    if random(0, 10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { print("ACCIDENT!") }
    
    let frequency = (note+octave).midiNoteToFrequency()
    if random(0, 6) > 1.0 {
        clarinet.trigger(frequency: frequency, amplitude: 0.1)
    } else {
        clarinet.stop()
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

