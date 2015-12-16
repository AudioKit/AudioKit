//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## 3D Spatialization
//: ### Here, we demonstrate how to place sound in a 3D space using `AKSpatialMixer`. Sound is the sense most strongly attuned for localization. In order to create convincing 3D virual environments, it's important to have a great soundscape so that your users are able to feel properly oriented while using your app.
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
