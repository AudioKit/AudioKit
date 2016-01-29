//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDynamicsProcessor
//: ### Add description
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

//: Next, we'll connect the audio sources to a dynamics processor
let inputMix = AKMixer(mic, player)
var dynamicsProcessor = AKDynamicsProcessor(inputMix)

//: Set the parameters of the dynamics processor here
dynamicsProcessor.threshold = -20 // dB
dynamicsProcessor.headRoom = 5 // dB
dynamicsProcessor.expansionRatio = 2 // rate
dynamicsProcessor.expansionThreshold = 2 // rate
dynamicsProcessor.attackTime = 0.001 // secs
dynamicsProcessor.releaseTime = 0.05 // secs
dynamicsProcessor.masterGain = 0 // dB

var dynamicsProcessorWindow = AKDynamicsProcessorWindow(dynamicsProcessor)

AudioKit.output = dynamicsProcessor
AudioKit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
