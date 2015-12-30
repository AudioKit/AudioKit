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
let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

//: The following nodes are both acting on the original player node
var ringMod = AKRingModulator(player)
var delay = AKDelay(player)
delay.time = 0.01
delay.feedback = 80
delay.dryWetMix = 100

//: Any number of inputs can be equally summed into one output, including the original player, allowing us to create dry/wet mixes even for effects that don't have that property by default
let mixer = AKMixer(delay, ringMod, player)

audiokit.audioOutput = mixer
audiokit.start()
player.play()

let plotView = AKOutputWaveformPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
