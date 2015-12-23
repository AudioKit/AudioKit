//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDecimator
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

//: Next, we'll connect the audio sources to a decimator
let inputMix = AKMixer(mic, player)
var decimator = AKDecimator(inputMix)

//: Set the parameters of the decimator here
decimator.decimation =  50 // Percent
decimator.rounding = 50 // Percent
decimator.mix = 50 // Percent

var decimatorWindow = AKDecimatorWindow(decimator)

audiokit.audioOutput = decimator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
