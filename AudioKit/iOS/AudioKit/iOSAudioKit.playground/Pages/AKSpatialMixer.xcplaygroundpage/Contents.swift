//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKSpatialMixer
//: ### Add description
import XCPlayground
import AudioKit
import AVFoundation

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let file = NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let spatialMixer = AKSpatialMixer(player)

//: Set the parameters here
spatialMixer.azimuth = 90

audiokit.audioOutput = spatialMixer
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
