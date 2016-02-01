//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Shelf Filter
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var lowShelfFilter = AKLowShelfFilter(player)

//: Set the parameters of the Low-Shelf Filter here
lowShelfFilter.cutoffFrequency = 800 // Hz
lowShelfFilter.gain = -100 // dB

AudioKit.output = lowShelfFilter
AudioKit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if lowShelfFilter.isBypassed {
        lowShelfFilter.start()
    } else {
        lowShelfFilter.bypass()
    }
    lowShelfFilter.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
