//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Balancing Nodes
//: Sometimes you want to ensure that an audio signal that you're processing
//: remains at a volume similar to where it started.
//: Such an application is perfect for the AKBalancer node.
import PlaygroundSupport
import AudioKit

//: This section prepares the players
let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources)
var source = try AKAudioPlayer(file: file)
source.looping = true

let highPassFiltering = AKHighPassFilter(source, cutoffFrequency: 900)
let lowPassFiltering = AKLowPassFilter(highPassFiltering, cutoffFrequency: 300)

//: At this point you don't have much signal left, so you balance it against the original signal!
let rebalancedWithSource = AKBalancer(lowPassFiltering, comparator: source)

AudioKit.output = rebalancedWithSource
AudioKit.start()
source.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Balancing Nodes")

        addLabel("Listen to the difference in volume:")
        addSubview(AKBypassButton(node: rebalancedWithSource))
    }

}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
