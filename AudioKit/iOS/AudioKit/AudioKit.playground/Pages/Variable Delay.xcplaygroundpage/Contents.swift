//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Variable Delay
//: ### When you smooth vary effect parameters, you get completely new kinds of effects.  
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var delay = AKVariableDelay(player)

//: Set the parameters of the delay here 
delay.time = 0.1 // seconds
AudioKit.output = delay
AudioKit.start()
player.play()

var t = 0.0
let timeStep = 0.02

AKPlaygroundLoop(every: timeStep) {
    
//: Vary the delay time between 0.0 and 0. 4 in a sinusoid at 0.5 hz
    let delayModulationHz = 0.5
    let delayModulation = (1.0 - cos(2 * 3.14 * delayModulationHz * t)) * 0.02
    delay.time = delayModulation
    
//: Vary the feedback between zero and 1 in a sinusoid at 0.5Hz
    let feedbackModulationHz = 0.5
    let feedbackModulation = (1.0 - sin(2 * 3.14 * feedbackModulationHz * t)) * 0.5
    delay.feedback = feedbackModulation
    
    t = t + timeStep
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
