//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Peak Limiter
//: ### A peak limiter will set a hard limit on the amplitude of an audio signal. They're espeically useful for any type of live input processing, when you may not be in total control of the audio signal you're recording or processing.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var peakLimiter = AKPeakLimiter(player)

//: Set the parameters of the Peak Limiter here
peakLimiter.attackTime = 0.001 // seconds
peakLimiter.decayTime  = 0.01  // seconds
peakLimiter.preGain    = 10 // dB (-40 to 40)

AudioKit.output = peakLimiter
AudioKit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if peakLimiter.isBypassed {
        peakLimiter.start()
    } else {
        peakLimiter.bypass()
    }
    peakLimiter.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
