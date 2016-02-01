//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Splitting Nodes
//: ### All nodes in AudioKit can have multiple destinations, the only caveat is that all of the destinations do have to eventually be mixed back together and none of the parallel signal paths can have any time stretching.
import XCPlayground
import AudioKit
import AVFoundation

//: This section prepares the players
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
let player1Window = AKAudioPlayerWindow(player, title: "Drums")

var delay = AKDelay(player)
let delayWindow = AKDelayWindow(delay)

var ringMod = AKRingModulator(player)
let ringModWindow = AKRingModulatorWindow(ringMod)

//: Any number of inputs can be equally summed into one output
let mixer = AKMixer(delay, ringMod, player)

AudioKit.output = mixer
AudioKit.start()

let plotView = AKOutputWaveformPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
