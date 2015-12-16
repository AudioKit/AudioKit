//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKBandPassFilter
//: ### Band-pass filters allow audio above a specified frequency range and bandwidth to pass through to an output. The center frequency is the starting point from where the frequency limit is set. Adjusting the bandwidth sets how far out above and below the center frequency the frequency band should be. Anything above that band should pass through. 
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let bandPassFilter = AKBandPassFilter(player)

//: Set the parameters of the band pass filter here
bandPassFilter.centerFrequency = 5000 // Hz
bandPassFilter.bandwidth = 600  // Cents

audiokit.audioOutput = bandPassFilter
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
