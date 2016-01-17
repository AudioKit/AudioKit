//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Drum Synthesizer Instruments
//: ### can be hooked up to midi or sequencers
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

var bd = AKDrumSynthKickInst(voiceCount: 1)
var sd = AKDrumSynthSnareInst(voiceCount: 1)
var mx = AKMixer()
audiokit.audioOutput = mx
mx.connect(bd)
mx.connect(sd)
audiokit.start()


AKPlaygroundLoop(frequency: 2) {
    print("boom")
    bd.playNote(60, velocity: 100)
    bd.stopNote(60)
    usleep(500000)
    sd.stopNote(60)
    let vel = Int(random(1,100))
    print("chik")
    sd.playNote(60, velocity: vel)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
