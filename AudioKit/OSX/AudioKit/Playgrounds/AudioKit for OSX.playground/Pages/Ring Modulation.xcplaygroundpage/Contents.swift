//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Ring Modulation
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("leadloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var ringModulator = AKRingModulator(player)

//: Set the parameters of the Ring Modulator here
ringModulator.frequency1 = 440 // Hertz
ringModulator.frequency2 = 660 // Hertz
ringModulator.balance = 0.5 //  Normalized Value: 0 - 1
ringModulator.mix     = 0.5 //  Normalized Value: 0 - 1

AudioKit.output = ringModulator
AudioKit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if ringModulator.isBypassed {
        ringModulator.start()
    } else {
        ringModulator.bypass()
    }
    ringModulator.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
