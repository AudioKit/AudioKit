//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Stereo Panning
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")

var player = AKAudioPlayer(file!)
player.looping = true

var panner = AKPanner(player)
panner.pan = 1

audiokit.audioOutput = panner
audiokit.start()
player.play()

AKPlaygroundLoop(every: 1) {
    if panner.pan == -1 {
        panner.pan = 1
    } else {
        panner.pan = -1
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
