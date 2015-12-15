//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKVariableDelay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let delay = AKVariableDelay(player)

//: Set the parameters of the delay here delay.time = 0.1 // seconds
audiokit.audioOutput = delay
audiokit.start()
player.play()

var t = 0.0
let timeStep = 0.02

let updater = AKPlaygroundLoop(every: timeStep) {
    
//: Vary the delay time between 0.0 and 0. 4 in a sinusoid at 0.5 hz
    let delayModulationHz = 0.5
    let delayModulation = (1.0 - cos(2 * 3.14 * delayModulationHz * t)) * 0.02
    delay.time = Float(delayModulation)
    
//: Vary the feedback between zero and 1 in a sinusoid at 0.5Hz
    let feedbackModulationHz = 0.5
    let feedbackModulation = (1.0 - sin(2 * 3.14 * feedbackModulationHz * t)) * 0.5
    delay.feedback = Float(feedbackModulation)
    
    t = t + timeStep
}

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
