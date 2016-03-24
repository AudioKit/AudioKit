//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Drum Synthesizers
//: ### These can also be hooked up to MIDI or a sequencer.
import XCPlayground
import AudioKit

//: Here we set up the instruments, which can be polyphnic, but we only need mono for this example
var kick = AKSynthKick(voiceCount: 1)
var snare = AKSynthSnare(voiceCount: 1, duration: 0.07)

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
    let randomHit = randomInt(0...3) == 0
    
    if onFirstBeat || randomHit {
        kick.playNote(60, velocity: 100)
        kick.stopNote(60)
    }
    
    if everyOtherBeat {
        let velocity = randomInt(1...100)
        snare.playNote(60, velocity: velocity)
        snare.stopNote(60)
    }
    i += 1
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
