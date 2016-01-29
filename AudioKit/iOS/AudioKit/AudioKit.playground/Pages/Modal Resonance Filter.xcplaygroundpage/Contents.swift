//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Modal Resonance Filter
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var filter = AKModalResonanceFilter(player)

filter.frequency = 300 // Hz
filter.qualityFactor = 50

let loweredVolume = AKBooster(filter, gain: 0.2)

AudioKit.output = loweredVolume
AudioKit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
