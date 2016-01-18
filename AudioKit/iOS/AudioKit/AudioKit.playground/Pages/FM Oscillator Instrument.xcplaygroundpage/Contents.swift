//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FM Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

var fm = AKFMSynth(voiceCount: 12)
audiokit.audioOutput = fm
audiokit.start()


AKPlaygroundLoop(frequency: 1) {
    
    fm.carrierMultiplier = random(1, 4)
    fm.modulationIndex = random(1, 5)
    fm.modulatingMultiplier = random(1, 3)
    fm.attackDuration = random(0,1)
    fm.releaseDuration = random(0,1)
    let note = randomInt(40...80)
    fm.playNote(note, velocity: 10)
    sleep(1)
    fm.stopNote(note)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
