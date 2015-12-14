//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKRingModulator
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("leadloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let ringModulator = AKRingModulator(player)

//: Set the parameters of the ring modulator here
ringModulator.frequency1 = 440 // Hertz
ringModulator.frequency2 = 660 // Hertz
ringModulator.balance = 50 // Percent
ringModulator.mix = 50 // Percent

audiokit.audioOutput = ringModulator
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
