//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Fatten Effect
//: ### This is a cool fattening effect that Matthew Flecher wanted for the Analog Synth X project, so it was developed here in a playground first.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")

//: Here we set up a player to the loop the file's playback
var player = AKAudioPlayer(file!)
player.looping = true

//: Define parameters that will be required
let input = AKStereoOperation.input
let fattenTimeParameter = AKOperation.parameters(0)
let fattenMixParameter = AKOperation.parameters(1)

let fattenOperation = AKStereoOperation(
    "\(input) dup \(1 - fattenMixParameter) * swap 0 \(fattenTimeParameter) 1.0 vdelay \(fattenMixParameter) * +")
let fatten = AKOperationEffect(player, stereoOperation: fattenOperation)

AudioKit.output = fatten
AudioKit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    let time = random(0.03, 0.1)
    let mix = random(0.3, 1.0)
    fatten.parameters = [time, mix];
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)



