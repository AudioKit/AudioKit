//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Modal Resonance Filter
//: ### Add description

import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let filter = AKModalResonanceFilter(player)

filter.frequency = 300 // Hz
filter.qualityFactor = 50

let loweredVolume = AKGain.init(filter, gain: 0.2)

audiokit.audioOutput = loweredVolume
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
