//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Roland TB-303 Filter
//: ### Write description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var filter = AKRolandTB303Filter(player)

//: Set the parameters of the filter here
filter.cutoffFrequency = 1350
filter.resonance = 0.8

audiokit.audioOutput = filter
audiokit.start()
player.play()


var t = 0.0
let timeStep = 0.02

AKPlaygroundLoop(every: timeStep) {
    
    let hz = 2.0
    filter.cutoffFrequency = (1.0 - cos(2 * 3.14 * hz * t)) * 600 + 700
//    filter.resonance = (1.0 - sin(2 * 3.14 * 2 * hz * t)) * 0.5
    
    t = t + timeStep
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
