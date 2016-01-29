//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Balancing Nodes
//: ### Sometimes you want to ensure that an audio signal that you're processing remains at a volume similar to where it started.  Such an application is perfect for the AKBalancer node.
import XCPlayground
import AudioKit

//: This section prepares the players
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var source = AKAudioPlayer(file!)
source.looping = true

let highPassFiltering = AKHighPassFilter(source, cutoffFrequency: 900)
let lowPassFiltering = AKLowPassFilter(highPassFiltering, cutoffFrequency: 300)

//: At this point you don't have much signal left, so you balance it against the original signal!
let rebalancedWithSource = AKBalancer(lowPassFiltering,  comparator: source)

AudioKit.output = rebalancedWithSource
AudioKit.start()
source.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if rebalancedWithSource.isBypassed {
        rebalancedWithSource.start()
    } else {
        rebalancedWithSource.bypass()
    }
    rebalancedWithSource.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

