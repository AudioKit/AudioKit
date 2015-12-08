//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Connecting Nodes
//: ### Playing audio is great, but now let's process that audio. Now that you're up and running, let's take it a step further by loading up an audio file and processing it. We're going to do this by connecting nodes together. A node is simply an object that will take in audio input, process it, and pass the processed audio to another node, or to the Digital-Analog Converter (speaker). 
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")

//: Here we set up a player to the loop the file's playback
let player = AKAudioPlayer(file!)
player.looping = true

//: Next we'll connect the audio to a delay
let delay = AKDelay(player)

//: Set the parameters of the delay here
delay.time = 0.1 // seconds
delay.feedback  = 80 // Percent
delay.dryWetMix = 60 // Percent

//: You can continue add more nodes as you wish, and here we add a reverb
let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.Cathedral)

audiokit.audioOutput = reverb
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
