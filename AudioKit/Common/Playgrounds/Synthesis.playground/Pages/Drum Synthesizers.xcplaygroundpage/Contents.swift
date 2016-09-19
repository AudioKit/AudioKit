//: ## Drum Synthesizers
//: These can also be hooked up to MIDI or a sequencer.
import PlaygroundSupport
import AudioKit

//: Set up instruments:
var kick = AKSynthKick()
var snare = AKSynthSnare(duration: 0.07)

var mix = AKMixer(kick, snare)
var reverb = AKReverb(mix)

AudioKit.output = reverb
AudioKit.start()
reverb.loadFactoryPreset(.MediumRoom)

//: Generate a cheap electro beat
var counter = 0
AKPlaygroundLoop(frequency: 4.44) {

    let onFirstBeat = counter == 0
    let everyOtherBeat = counter % 4 == 2
    let randomHit = (0...3).randomElement() == 0

    if onFirstBeat || randomHit {
        kick.play(noteNumber:60, velocity: 100)
        kick.stop(noteNumber:60)
    }

    if everyOtherBeat {
        let velocity = (1...100).randomElement()
        snare.play(noteNumber:60, velocity: velocity)
        snare.stop(noteNumber:60)
    }
    counter += 1
}

PlaygroundPage.current.needsIndefiniteExecution = true
