//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Balancing Nodes
//: Sometimes you want to ensure that an audio signal that you're processing
//: remains at a volume similar to where it started.
//: Such an application is perfect for the AKBalancer node.
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

//: This section prepares the players
let file = try AKAudioFile(readFileName: "drumloop.wav")
var source = try AKAudioPlayer(file: file)
source.looping = true

let highPassFiltering = AKHighPassFilter(source, cutoffFrequency: 900)
let lowPassFiltering = AKLowPassFilter(highPassFiltering, cutoffFrequency: 300)

//: At this point you don't have much signal left, so you balance it against the original signal!
let rebalancedWithSource = AKBalancer(lowPassFiltering, comparator: source)

engine.output = rebalancedWithSource
try engine.start()
source.play()

//: User Interface Set up

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Balancing Nodes")

        addLabel("Listen to the difference in volume:")

        addView(AKButton(title: "Balancing") { button in
            let node = rebalancedWithSource
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Balancing" : "Bypassed"
        })
    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
