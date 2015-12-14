//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mixing Nodes
//: ### So, what about connecting two operations to output instead of having all operations sequential? To do that, you'll need a mixer.
import XCPlayground
import AudioKit

//: This section prepares the players
let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file1 = bundle.pathForResource("drumloop",   ofType: "wav")
let file2 = bundle.pathForResource("guitarloop", ofType: "wav")
let player1 = AKAudioPlayer(file1!)
player1.looping = true
let player2 = AKAudioPlayer(file2!)
player2.looping = true

//: Any number of inputs can be summed into one output
let mixer = AKMixer(player1, player2)

audiokit.audioOutput = mixer
audiokit.start()

player1.play()
player2.play()

//: Adjust the individual track volumes here
player1.volume = 0.8
player2.volume = 0.7
player1.pan = 0.1
player2.pan = -0.1

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
