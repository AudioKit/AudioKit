//: ## Drum Synthesizers
//: These can also be hooked up to MIDI or a sequencer.

import AudioKit

//: Set up instruments:
var kick = AKSynthKick()
var snare = AKSynthSnare(duration: 0.07)

var mix = AKMixer(kick, snare)
var reverb = AKReverb(mix)
AudioKit.output = reverb
AudioKit.start()
reverb.loadFactoryPreset(.mediumRoom)

//: Generate a cheap electro beat
var counter = 0
AKPlaygroundLoop(frequency: 5) {

    let onFirstBeat = counter % 4 == 0
    let everyOtherBeat = counter % 4 == 2
    let randomHit = Array(0...3).randomElement() == 0

    if onFirstBeat || randomHit {
        kick.play(noteNumber: MIDINoteNumber(60), velocity: MIDIVelocity(100))
        kick.stop(noteNumber: 60)
    }

    if everyOtherBeat {
        let velocity = MIDIVelocity(Array(0...100).randomElement())
        snare.play(noteNumber: 60, velocity: velocity)
        snare.stop(noteNumber: 60)
    }
    counter += 1
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
