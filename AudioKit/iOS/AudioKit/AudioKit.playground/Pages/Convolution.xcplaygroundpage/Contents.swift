//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Convolution
//: ### Allows you to create a large variety of effects, usually reverbs or environments, but it could also be for modeling.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

let stairwell = bundle.URLForResource("Impulse Responses/stairwell", withExtension: "wav")!
let dish = bundle.URLForResource("Impulse Responses/dish", withExtension: "wav")!

var stairwellConvolution = AKConvolution.init(player, impulseResponseFileURL: stairwell, partitionLength: 8192)
var dishConvolution = AKConvolution.init(player, impulseResponseFileURL: dish, partitionLength: 8192)

var mixer = AKDryWetMixer(stairwellConvolution, dishConvolution, balance: 1)

AudioKit.output = mixer
AudioKit.start()
stairwellConvolution.start()
dishConvolution.start()
player.play()

var increment = 0.01

AKPlaygroundLoop(every: 3.428/100.0) { () -> () in
    mixer.balance += increment
    if mixer.balance >= 1 && increment > 0 {
        increment = -0.01
    }
    if mixer.balance <= 0 && increment < 0 {
        increment = 0.01
    }
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
