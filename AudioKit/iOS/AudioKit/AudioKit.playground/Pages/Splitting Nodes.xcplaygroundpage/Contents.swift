//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Splitting Nodes
//: ### All nodes in AudioKit can have multiple destinations, the only
//: ### caveat is that all of the destinations do have to eventually be
//: ### mixed back together and none of the parallel signal paths
//: ### can have any time stretching.
import XCPlayground
import AudioKit

//: Prepare the source audio player
let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

//: The following nodes are both acting on the original player node
var ringMod = AKRingModulator(player)

var delay = AKDelay(player)
delay.time = 0.01
delay.feedback = 0.8
delay.dryWetMix = 1

//: Any number of inputs can be equally summed into one output,
//: including the original player, allowing us to create dry/wet mixes
//: even for effects that don't have that property by default
let mixer = AKMixer(player, delay)

AudioKit.output = mixer
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@nex
