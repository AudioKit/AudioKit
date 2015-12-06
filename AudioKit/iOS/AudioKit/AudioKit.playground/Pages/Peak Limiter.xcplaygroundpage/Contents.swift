//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKPeakLimiter
//: ### A peak limiter will set a hard limit on the amplitude of an audio signal. They're espeically useful for any type of live input processing, when you may not be in total control of the audio signal you're recording or processing.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let peakLimiter = AKPeakLimiter(player)

//: Set the parameters of the Peak Limiter here
peakLimiter.attackTime = 0.001 // seconds
peakLimiter.decayTime  = 0.01  // seconds
peakLimiter.preGain    = 10 // dB (-40 to 40)

audiokit.audioOutput = peakLimiter
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
