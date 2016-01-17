//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Drum Synthesizer Instruments
//: ### can be hooked up to midi or sequencers
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

var kick = AKSynthKick(voiceCount: 1)
var snare = AKSynthSnare(voiceCount: 1, duration: 0.07)
var mix = AKMixer(kick, snare)

audiokit.audioOutput = mix
audiokit.start()

var i = 0

//generate cheap electro
AKPlaygroundLoop(frequency: 4.44) {
    
    let onFirstBeat = i == 0
    let everyOtherBeat = i % 4 == 2
    let randomHit = randomInt(0...3) == 0
    
    if onFirstBeat || randomHit {
        //print("boom")
        kick.playNote(60, velocity: 100)
        kick.stopNote(60)
    }
    
    if everyOtherBeat {
        //print("chik")
        let velocity = randomInt(1...100)
        snare.playNote(60, velocity: velocity)
        snare.stopNote(60)
    }
    i++
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
