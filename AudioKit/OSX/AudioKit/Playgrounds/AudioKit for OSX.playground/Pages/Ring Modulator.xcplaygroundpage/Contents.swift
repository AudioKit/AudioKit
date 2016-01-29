//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Ring Modulator
//:
import XCPlayground
import AudioKit

//: This section prepares the player and the microphone
var mic = AKMicrophone()
mic.volume = 0
let micWindow = AKMicrophoneWindow(mic)

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("leadloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
let playerWindow = AKAudioPlayerWindow(player)

//: Next, we'll connect the audio sources to a ring modulator
let inputMix = AKMixer(mic, player)
var ringModulator = AKRingModulator(inputMix)

//: Set the parameters of the ring modulator here
ringModulator.frequency1 = 440 // Hertz
ringModulator.frequency2 = 660 // Hertz
ringModulator.balance = 0.5
ringModulator.mix = 0.5

var ringModulatorWindow = AKRingModulatorWindow(ringModulator)

AudioKit.output = ringModulator
AudioKit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
