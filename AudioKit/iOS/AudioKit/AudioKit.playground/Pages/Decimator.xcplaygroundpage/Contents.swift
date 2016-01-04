//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDecimator
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var decimator = AKDecimator(player)

//: Set the parameters of the decimator here
decimator.decimation =  20 // Percent
decimator.rounding = 2 // Percent
decimator.mix = 50 // Percent

audiokit.audioOutput = decimator
audiokit.start()
player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if decimator.isBypassed {
        decimator.start()
    } else {
        decimator.bypass()
    }
    decimator.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
