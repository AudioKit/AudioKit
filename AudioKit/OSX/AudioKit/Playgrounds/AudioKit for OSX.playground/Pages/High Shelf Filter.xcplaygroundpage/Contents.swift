//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## High Shelf Filter
//:
import XCPlayground
import AudioKit

//: This section prepares the player and the microphone
var mic = AKMicrophone()
mic.volume = 0
let micWindow = AKMicrophoneWindow(mic)

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
let playerWindow = AKAudioPlayerWindow(player)

//: Next, we'll connect the audio sources to a high shelf filter
let inputMix = AKMixer(mic, player)
var highShelfFilter = AKHighShelfFilter(inputMix)

//: Set the parameters of the-high shelf filter here
highShelfFilter.cutOffFrequency = 10000 // Hz
highShelfFilter.gain = 0 // dB

var highShelfFilterWindow = AKHighShelfFilterWindow(highShelfFilter)

AudioKit.output = highShelfFilter
AudioKit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
