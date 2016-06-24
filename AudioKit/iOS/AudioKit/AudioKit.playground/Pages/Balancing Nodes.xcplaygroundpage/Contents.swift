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
let file = try? AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)


var source = try? AKAudioPlayer(file: file!)
source!.looping = true

let highPassFiltering = AKHighPassFilter(source!, cutoffFrequency: 900)
let lowPassFiltering = AKLowPassFilter(highPassFiltering, cutoffFrequency: 300)

//: At this point you don't have much signal left, so you balance it against the original signal!
let rebalancedWithSource = AKBalancer(lowPassFiltering, comparator: source!)

AudioKit.output = rebalancedWithSource
AudioKit.start()
source!.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    override func setup() {
        addTitle("Balancing Nodes")
        
        addLabel("Listen to the difference in volume:")
        addButton("Balance", action: #selector(start))
        addButton("Bypass", action: #selector(bypass))
    }
    
    func start() {
        rebalancedWithSource.start()
    }
    func bypass() {
        rebalancedWithSource.bypass()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 200))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
