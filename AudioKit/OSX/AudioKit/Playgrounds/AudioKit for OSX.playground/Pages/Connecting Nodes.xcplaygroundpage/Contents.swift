//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Connecting Nodes
//: ### Playing audio is great, but now let's process that audio. Now that you're up and running, let's take it a step further by loading up an audio file and processing it. We're going to do this by connecting nodes together. A node is simply an object that will take in audio input, process it, and pass the processed audio to another node, or to the Digital-Analog Converter (speaker). 
import XCPlayground
import AudioKit

//: This section prepares the player and the microphone
var mic = AKMicrophone()
mic.volume = 0
let micWindow = AKMicrophoneWindow(mic)

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
let playerWindow = AKAudioPlayerWindow(player)

//: Next, we'll connect the audio sources to a delay
let inputMix = AKMixer(mic, player)
var delay = AKDelay(inputMix)

//: Set the parameters of the delay here
delay.time = 0.1 // seconds
delay.feedback  = 0.8 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

var delayWindow  = AKDelayWindow(delay)

//: You can continue add more nodes as you wish, and here we add a reverb
let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.Cathedral)

AudioKit.output = reverb
AudioKit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
