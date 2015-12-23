//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Introduction
//: ### Making sure things work on your system by playing back audio with AKAudioPlayer
import XCPlayground
import AudioKit

//: All AudioKit powered apps need a reference to the AKManager
let audiokit = AKManager.sharedInstance

//: Try Changing "mixloop" to "drumloop"
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
let player = AKAudioPlayer(file!)

//: Next set AudioKit's main audio output to be this player
audiokit.audioOutput = player

//: Start up AudioKit to connect all nodes to the system
audiokit.start()

//: Start the player's audio playback
player.play()

//: Because we need to keep this playground running to playback the audio, we add the following line at the bottom to most playgrounds (or in some cases, we can set up a never ending loop)
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
