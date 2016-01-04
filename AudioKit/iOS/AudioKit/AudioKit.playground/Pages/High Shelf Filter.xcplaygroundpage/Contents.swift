//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKHighShelfFilter
//: ### A high-pass filter takes an audio signal as an input, and cuts out the low-frequency components of the audio signal, allowing for the higher frequency components to "pass through" the filter.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var highShelfFilter = AKHighShelfFilter(player)
var h2 = AKHighShelfFilter(highShelfFilter)
//: Set the parameters of the High-Shelf Filter here
highShelfFilter.cutOffFrequency = 2000 // Hz
highShelfFilter.gain = 40 // dB

audiokit.audioOutput = h2
audiokit.start()
player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if highShelfFilter.isBypassed {
        highShelfFilter.start()
    } else {
        highShelfFilter.bypass()
    }
    highShelfFilter.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
