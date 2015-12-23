//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDistortion
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: This section prepares the player and the microphone
var mic = AKMicrophone()
mic.volume = 0
let micWindow = AKMicrophoneWindow(mic)

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
let playerWindow = AKAudioPlayerWindow(player)

//: Next, we'll connect the audio sources to distortion
let inputMix = AKMixer(mic, player)
var distortion = AKDistortion(inputMix)

//: Set the parameters of the distortion here
distortion.delay = 0.1 // Milliseconds
distortion.decay = 1.0 // Rate
distortion.delayMix = 50 // Percent

//: These are the decimator-specific parameters
distortion.decimation = 50 // Percent
distortion.rounding = 0 // Percent
distortion.decimationMix = 50 // Percent
distortion.linearTerm = 50 // Percent
distortion.squaredTerm = 50 // Percent
distortion.cubicTerm = 50 // Percent
distortion.polynomialMix = 50 // Percent
distortion.ringModFreq1 = 100 // Hertz
distortion.ringModFreq2 = 100 // Hertz
distortion.ringModBalance = 50 // Percent
distortion.ringModMix = 0 // Percent
distortion.softClipGain = -6 // dB
distortion.finalMix = 50 // Percent

var distortionWindow = AKDistortionWindow(distortion)

audiokit.audioOutput = distortion
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
