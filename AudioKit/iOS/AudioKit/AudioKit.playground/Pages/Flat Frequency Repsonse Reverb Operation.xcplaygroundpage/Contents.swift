//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Flat Frequency Response Reverb Operation
//: ### Add Description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Music Example
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true

// Note this is not currently working correctly...
let duration = sineWave(frequency: 0.1.ak, amplitude: 0.1.ak) + 0.1

let reverb = AKOperation.input.reverberatedWithFlatFrequencyResponse(reverbDuration: duration, loopDuration: 1)
let effect = AKNode.effect(player, operation: reverb)

audiokit.audioOutput = effect
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
