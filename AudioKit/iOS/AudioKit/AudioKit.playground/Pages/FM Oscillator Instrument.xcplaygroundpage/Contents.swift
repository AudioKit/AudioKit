//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FM Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

var fm = AKFMOscillatorInstrument(voiceCount: 12)
audiokit.audioOutput = fm
audiokit.start()


AKPlaygroundLoop(frequency: 1) {
    
    fm.carrierMultiplier = random(1, 4)
    fm.modulationIndex = random(1, 5)
    fm.modulatingMultiplier = random(1, 3)
    fm.attackDuration = random(0,1)
    fm.releaseDuration = random(0,1)
    let note = UInt8(randomInt(40...80))
    fm.startVoice(0, note: note, withVelocity: 10, onChannel: 0)
    sleep(1)
    fm.stopVoice(0, note: note, onChannel: 0)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
