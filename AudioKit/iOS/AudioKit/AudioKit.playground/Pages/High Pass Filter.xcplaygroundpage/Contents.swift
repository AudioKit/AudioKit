//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKHighPassFilter
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var highPassFilter = AKHighPassFilter(player)

//: Set the parameters of the High-Pass Filter here
highPassFilter.cutoffFrequency = 1000 // Hz
highPassFilter.resonance = 10 // dB

audiokit.audioOutput = highPassFilter
audiokit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if highPassFilter.isBypassed {
        highPassFilter.start()
    } else {
        highPassFilter.bypass()
    }
    highPassFilter.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
