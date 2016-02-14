//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Variable Delay
//: ### When you smoothly vary effect parameters, you get completely new kinds of effects.
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

var time = 0.0
let timeStep = 0.02

AKPlaygroundLoop(every: timeStep) {
    
    //: Vary the delay time between 0.0 and 0.2 in a sinusoid at 2 hz
    let delayModulationHz = 2.0
    let delayModulation = (1.0 - cos(2 * 3.14 * delayModulationHz * time)) * 0.2
    delay.time = delayModulation
    
    time += timeStep
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
