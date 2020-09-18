//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Balancing Nodes
//: Sometimes you want to ensure that an audio signal that you're processing
//: remains at a volume similar to where it started.
//: Such an application is perfect for the Balancer node.
import AudioKit

//: This section prepares the players
let file = try AVAudioFile(readFileName: "drumloop.wav")
var source = try AudioPlayer(file: file)
source.looping = true

let highPassFiltering = HighPassFilter(source, cutoffFrequency: 900)
let lowPassFiltering = LowPassFilter(highPassFiltering, cutoffFrequency: 300)

//: At this point you don't have much signal left, so you balance it against the original signal!
let rebalancedWithSource = Balancer(lowPassFiltering, comparator: source)

engine.output = rebalancedWithSource
try engine.start()
source.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Balancing Nodes")

        addLabel("Listen to the difference in volume:")

        addView(Button(title: "Balancing") { button in
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
