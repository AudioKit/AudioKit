//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKParametricEQ
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: This section prepares the player and the microphone
let mic = AKMicrophone()
mic.volume = 0
let micWindow = AKMicrophoneWindow(mic)

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let playerWindow = AKAudioPlayerWindow(player)

//: Next, we'll connect the audio sources to a parametric equalizer
let inputMix = AKMixer(mic, player)
let parametricEQ = AKParametricEQ(inputMix)

//: Set the parameters of the parametric equalizer here
parametricEQ.centerFrequency = 2000 // Hz
parametricEQ.q = 1.0 // Hz
parametricEQ.gain = 0 // dB

var parametricEQWindow = AKParametricEQWindow(parametricEQ)

audiokit.audioOutput = parametricEQ
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
