//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKLowPassFilter
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: This section prepares the player and the microphone
var mic = AKMicrophone()
mic.volume = 0
let micWindow = AKMicrophoneWindow(mic)

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
let playerWindow = AKAudioPlayerWindow(player)

//: Next, we'll connect the audio sources to a low pass filter
let inputMix = AKMixer(mic, player)
var lowPassFilter = AKLowPassFilter(inputMix)

//: Set the parameters of the low pass filter here
lowPassFilter.cutoffFrequency = 6900 // Hz
lowPassFilter.resonance = 0 // dB

var lowPassFilterWindow = AKLowPassFilterWindow(lowPassFilter)

audiokit.audioOutput = lowPassFilter
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
