//: [Previous](@previous)
//:
//: ---
//:
//: ## Introduction to AudioKit
//: ### Making sure things work on your system by playing back audio with AKAudioPlayer
import XCPlayground
import AudioKit

//: All AudioKit powered apps need a reference to the AKManager
let audiokit = AKManager.sharedInstance

//: Try Changing "PianoBassDrumLoop" to "808loop"
let file = NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)

audiokit.audioOutput = player
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [Next](@next)
