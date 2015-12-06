//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKLowPassFilter
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let lowPassFilter = AKLowPassFilter(player)

//: Set the parameters of the low pass filter here
lowPassFilter.cutoffFrequency = 1000 // Hz
lowPassFilter.resonance = 0 // dB

audiokit.audioOutput = lowPassFilter
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
