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
let file1 = bundle.pathForResource("808loop", ofType: "wav")
let file2 = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player1 = AKAudioPlayer(file1!)
player1.looping = true

let player2 = AKAudioPlayer(file2!)
player2.looping = true

//: Lets put the players through a gain node so that their relative volumes can be changed

let playback1 = AKGain(player1, gain: 2.0)
let playback2 = AKGain(player2, gain: 1.0)

//: Any number of inputs can be equally summed into one output
let mixer = AKMixer(playback1, playback2)

//: Next we'll just make sure we're always outputing the same overall volume
mixer.volume = 1.0 / (playback1.gain + playback2.gain)

audiokit.audioOutput = mixer
audiokit.start()
player1.play()
player2.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
