//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Introduction
//: ### Making sure things work on your system by playing back audio with AKAudioPlayer
import XCPlayground
import AudioKit

//: Try Changing "mixloop" to "drumloop"
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
let player = AKAudioPlayer(file!)

//: Next set AudioKit's main audio output to be this player
AudioKit.output = player

Audio//: Start up AudioKit to connect all nodes to the system
Kit.start()

playe//: Start the player's audio playback
r.play()

//: Because we need to keep this playground running to playback the audio, we add the following line at the bottom to most playgrounds (or in some cases, we can set up a never ending loop)
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
