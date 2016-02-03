//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Moog Ladder Filter
//: ### One of the coolest filters available in AudioKit is the Moog Ladder. It's based off of Robert Moog's iconic ladder filter, which was the first implementation of a voltage - controlled filter used in an analog synthesizer. As such, it was the first filter that gave the ability to use voltage control to determine the cutoff frequency of the filter. As we're dealing with a software implementation, and not an analog synthesizer, we don't have to worry about dealing with voltage control directly. However, by using this node, you can emulate some of the sounds of classic analog synthesizers in your app.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var moogLadder = AKMoogLadder(player)

//: Set the parameters of the Moog Ladder Filter here. Hertz is a common unit of measurement for a frequency parameter. TODO: find a non-terrible explanation of what "Cents" are.

moogLadder.cutoffFrequency = 300 // Hz
moogLadder.resonance = 0.6  

AudioKit.output = moogLadder
AudioKit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if moogLadder.isBypassed {
        moogLadder.start()
    } else {
        moogLadder.bypass()
    }
    moogLadder.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
