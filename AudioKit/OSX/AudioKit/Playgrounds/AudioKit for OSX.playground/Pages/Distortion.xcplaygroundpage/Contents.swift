//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Distortion
//: ### This playground provides access to Apple's built-in distortion effect that they lump together into one giant Audio Unit.  For clarity, the submodules to the distortion are also available as individual nodes themselves.
import XCPlayground
import AudioKit

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
distortion.delayMix = 0.5 // Normalized Value 0 - 1

//: These are the decimator-specific parameters
distortion.decimation = 0.5 // Normalized Value 0 - 1
distortion.rounding = 0.0 // Normalized Value 0 - 1
distortion.decimationMix = 0.5 // Normalized Value 0 - 1
distortion.linearTerm = 0.5 // Normalized Value 0 - 1
distortion.squaredTerm = 0.5 // Normalized Value 0 - 1
distortion.cubicTerm = 0.5 // Normalized Value 0 - 1
distortion.polynomialMix = 0.5 // Normalized Value 0 - 1
distortion.ringModFreq1 = 100 // Hertz
distortion.ringModFreq2 = 100 // Hertz
distortion.ringModBalance = 0.5 // Normalized Value 0 - 1
distortion.ringModMix = 0 // Percent
distortion.softClipGain = -6 // dB
distortion.finalMix = 0.5 // Normalized Value 0 - 1

var distortionWindow = AKDistortionWindow(distortion)

AudioKit.output = distortion
AudioKit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
