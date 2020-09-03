//: ## Drum Synthesizers
//: These can also be hooked up to MIDI or a sequencer.

import AudioKit

//: Set up instruments:
var kick = AKSynthKick()
var snare = AKSynthSnare(duration: 0.07)

var mix = AKMixer(kick, snare)
var reverb = AKReverb(mix)

//: Generate a cheap electro beat
var counter = 0
let beats = AKPeriodicFunction(frequency: 5) {
    let randomVelocity = MIDIVelocity(AUValue.random(in: 0...127))
    let onFirstBeat = counter % 4 == 0
    let everyOtherBeat = counter % 4 == 2
    let randomHit = Array(0...3).randomElement() == 0

    if onFirstBeat || randomHit {
        kick.play(noteNumber: MIDINoteNumber(60), velocity: randomVelocity)
        kick.stop(noteNumber: 60)
    }

    if everyOtherBeat {
        let velocity = MIDIVelocity(Array(0...100).randomElement()!)
        snare.play(noteNumber: 60, velocity: randomVelocity, channel: 0)
        snare.stop(noteNumber: 60)
    }
    counter += 1
}

engine.output = reverb
try engine.start(withPeriodicFunctions: beats)
reverb.loadFactoryPreset(.mediumRoom)
beats.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
