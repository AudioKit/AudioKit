//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## High Shelf Filter
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var highShelfFilter = AKHighShelfFilter(player)

//: Set the parameters of the High-Shelf Filter here
highShelfFilter.cutOffFrequency = 2000 // Hz
highShelfFilter.gain = 40 // dB

AudioKit.output = highShelfFilter
AudioKit.start()
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
