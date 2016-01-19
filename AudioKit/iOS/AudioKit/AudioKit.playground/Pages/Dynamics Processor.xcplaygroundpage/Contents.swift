//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDynamicsProcessor
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var dynamicsProcessor = AKDynamicsProcessor(player)

//: Set the parameters of the dynamics processor here
dynamicsProcessor.threshold = -20 // dB
dynamicsProcessor.headRoom = 0.1 // dB - similar to 'ratio' on most compressors
dynamicsProcessor.attackTime = 0.01 // secs
dynamicsProcessor.releaseTime = 0.25 // secs
dynamicsProcessor.expansionRatio = 1 // effectively bypassing the expansion by using raito of 1
dynamicsProcessor.expansionThreshold = 0 // rate
dynamicsProcessor.masterGain = 20 // dB - makeup gain

audiokit.audioOutput = dynamicsProcessor
audiokit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if dynamicsProcessor.isBypassed {
        dynamicsProcessor.start()
    } else {
        dynamicsProcessor.bypass()
    }
    dynamicsProcessor.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
