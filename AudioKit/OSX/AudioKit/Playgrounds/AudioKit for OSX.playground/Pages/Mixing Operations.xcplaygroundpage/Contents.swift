//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mixing Operations
//: ### So, what about connecting two operations to output instead of having all operations sequential? To do that, you'll need a mixer. (NFA note to self---talk about how mixers sum the output; illustrate with a block diagram). 
import XCPlayground
import AudioKit

//: This section prepares the players
let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file1 = bundle.pathForResource("808loop", ofType: "wav")
let file2 = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player1 = AKAudioPlayer(file1!)
player1.looping = true
let player1Window = AKAudioPlayerWindow(player1, title: "808 Loop")

let player2 = AKAudioPlayer(file2!)
player2.looping = true
let player2Window = AKAudioPlayerWindow(player2, title: "Full Band", xOffset: 640)

//: Any number of inputs can be equally summed into one output
let mixer = AKMixer(player1, player2)
mixer.volume = 0.5

audiokit.audioOutput = mixer
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
