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
var sd = AKDrumSynthSnareInst(voiceCount: 1, dur: 0.07)
var mx = AKMixer()
audiokit.audioOutput = mx
mx.connect(bd)
mx.connect(sd)
audiokit.start()

var i = 0

//generate cheap electro
AKPlaygroundLoop(frequency: 4.44) {
    let bdOrNot = randomInt(0...3)
    if(bdOrNot == 0 || i == 0){
        //print("boom")
        bd.playNote(60, velocity: 100)
        bd.stopNote(60)
    }
    let snrOrNot = i % 4
    if(snrOrNot == 2){
        let vel = Int(random(1,100))
        //print("chik")
        sd.playNote(60, velocity: vel)
        sd.stopNote(60)
    }
    i++
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
