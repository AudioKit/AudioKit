//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Shelf Filter
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

//: Next, we'll connect the audio sources to a low shelf filter
let inputMix = AKMixer(mic, player)
var lowShelfFilter = AKLowShelfFilter(inputMix)

//: Set the parameters of the low-shelf filter here
lowShelfFilter.cutoffFrequency = 80 // Hz
lowShelfFilter.gain = 0 // dB

var lowShelfFilterWindow = AKLowShelfFilterWindow(lowShelfFilter)

AudioKit.output = lowShelfFilter
AudioKit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
