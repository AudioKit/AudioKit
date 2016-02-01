//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Decimator
//: ### Decimation is a type of digital distortion like bit crushing, but instead of directly stating what bit depth and sample rate you want, it is done through setting "decimation" and "rounding" parameters.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var decimator = AKDecimator(player)

//: Set the parameters of the decimator here
decimator.decimation =  0.2 //  Normalized Value: 0 - 1
decimator.rounding = 0.02   //  Normalized Value: 0 - 1
decimator.mix = 0.5         //  Normalized Value: 0 - 1

AudioKit.output = decimator
AudioKit.start()
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
