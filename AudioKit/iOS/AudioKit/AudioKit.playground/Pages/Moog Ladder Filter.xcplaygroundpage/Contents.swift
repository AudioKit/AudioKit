//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKMoogLadder
//: ### One of the coolest filters available in AudioKitAU is the Moog Ladder. It's based off of Robert Moog's iconic ladder filter, which was the first implementation of a voltage - controlled filter used in an analog synthesizer. As such, it was the first filter that gave the ability to use voltage control to determine the cutoff frequency of the filter. As we're dealing with a software implementation, and not an analog synthesizer, we don't have to worry about dealing with voltage control directly. However, by using this node, you can emulate some of the sounds of classic analog synthesizers in your app. 

import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var moogLadder = AKMoogLadder(player)

//: Set the parameters of the Moog Ladder Filter here. Hertz is a common unit of measurement for a frequency parameter. TODO: find a non-terrible explanation of what "Cents" are.

moogLadder.cutoffFrequency = 300 // Hz
moogLadder.resonance = 0.6  // Cents

audiokit.audioOutput = moogLadder
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
