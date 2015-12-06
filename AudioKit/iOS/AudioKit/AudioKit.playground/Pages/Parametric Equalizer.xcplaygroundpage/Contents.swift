//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Parametric Equalizer
//: #### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let parametricEQ = AKParametricEQ(player)

//: Set the parameters of the parametric equalizer here
parametricEQ.centerFrequency = 1000 // Hz
parametricEQ.q = 1 // Hz
parametricEQ.gain = 10 // dB

audiokit.audioOutput = parametricEQ
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
