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
var player = AKAudioPlayer(file!)
player.looping = true

// Note this is not currently working correctly...
let duration = sineWave(frequency: 0.1).scaledTo(minimum: 0, maximum: 5)

let reverb = AKOperation.input.reverberatedWithFlatFrequencyResponse(reverbDuration: duration, loopDuration: 0.1)
let effect = AKOperationEffect(player, operation: reverb)

audiokit.audioOutput = effect
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
