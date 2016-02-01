//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## High Pass Filter
//: ### A high-pass filter takes an audio signal as an input, and cuts out the low-frequency components of the audio signal, allowing for the higher frequency components to "pass through" the filter.
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

//: Next, we'll connect the audio sources to a high pass filter
let inputMix = AKMixer(mic, player)
var highPassFilter = AKHighPassFilter(inputMix)

//: Set the parameters of the high pass filter here
highPassFilter.cutoffFrequency = 6900 // Hz
highPassFilter.resonance = 0 // dB

var highPassFilterWindow = AKHighPassFilterWindow(highPassFilter)

AudioKit.output = highPassFilter
AudioKit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
