//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKBandPassFilter
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

//: Next, we'll connect the audio sources to a band pass filter
let inputMix = AKMixer(mic, player)
var bandPassFilter = AKBandPassFilter(inputMix)

//: Set the parameters of the band pass filter here
bandPassFilter.centerFrequency = 5000 // Hz
bandPassFilter.bandwidth = 600  // Cents

var bandPassFilterWindow = AKBandPassFilterWindow(bandPassFilter)

audiokit.audioOutput = bandPassFilter
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
