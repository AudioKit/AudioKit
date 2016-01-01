//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Balancing Nodes
//: ### Sometimes you want to ensure that an audio signal that you're processing remains at a volume similar to where it started.  Such an application is perfect for the AKBalance node.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: This section prepares the players
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var source = AKAudioPlayer(file!)
source.looping = true

let highPassFiltering = AKHighPassFilter(source, cutoffFrequency: 900)
let lowPassFiltering = AKLowPassFilter(highPassFiltering, cutoffFrequency: 300)

//: At this point you don't have much signal left, so you balance it against the original signal!

let rebalancedWithSource = AKBalance(lowPassFiltering,  comparator: source)

audiokit.audioOutput = rebalancedWithSource
audiokit.start()
source.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
