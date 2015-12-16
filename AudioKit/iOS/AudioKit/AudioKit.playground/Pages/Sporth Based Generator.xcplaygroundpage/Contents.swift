//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKCustomGenerator
//: ### Just as you can create effect nodes with Sporth for AudioKit, you can also create custom generators. 
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let generator = AKCustomGenerator("0.1 1 sine 110 1760 biscale 0.6 sine dup")

audiokit.audioOutput = generator
audiokit.start()

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
