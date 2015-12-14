//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## 3D Spatialization
//: ### Placing the sound in a 3D environment using `AKSpatialMixer`
import XCPlayground
import AudioKit
import AVFoundation

let audiokit = AKManager.sharedInstance
let file = NSBundle.mainBundle().pathForResource("guitarloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true

let spatialMixer = AKSpatialMixer(player, azimuth: 0, elevation: 0, distance: 0)

audiokit.audioOutput = spatialMixer
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
