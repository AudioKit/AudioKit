//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Distortion
//: ### This playground provides access to apple's built-in distortion effect that they lump together into one giant Audio Unit.  For clarity, the submodules to the distortion are also available as solo nodes themselves.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let distortion = AKDistortion(player)

//: Delay parameters
distortion.delay = 0.1 // Milliseconds
distortion.decay = 1.0 // Rate
distortion.delayMix = 50 // Percent

//: Decimator parameters
distortion.decimation = 50 // Percent
distortion.rounding = 0 // Percent
distortion.decimationMix = 50 // Percent

//: Ring modulator parameters
distortion.ringModFreq1 = 100 // Hertz
distortion.ringModFreq2 = 100 // Hertz
distortion.ringModBalance = 50 // Percent
distortion.ringModMix = 0 // Percent


//: Polynomial parameters
distortion.linearTerm = 50 // Percent
distortion.squaredTerm = 50 // Percent
distortion.cubicTerm = 50 // Percent
distortion.polynomialMix = 50 // Percent

//: Gain and mix parameters
distortion.softClipGain = -6 // dB
distortion.finalMix = 50 // Percent

audiokit.audioOutput = distortion
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
