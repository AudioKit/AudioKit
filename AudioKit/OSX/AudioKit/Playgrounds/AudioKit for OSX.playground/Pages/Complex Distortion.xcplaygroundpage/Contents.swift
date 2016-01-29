//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Complex Distortion
//: ### This playground provides access to Apple's built-in distortion effect that they lump together into one giant Audio Unit.  For clarity, the submodules to the distortion are also available as individual nodes themselves.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var distortion = AKDistortion(player)

//: Delay parameters
distortion.delay = 0.1 // Milliseconds
distortion.decay = 1.0 // Rate
distortion.delayMix = 0.1 // Normalized Value: 0 - 1

//: Decimator parameters
distortion.decimation = 0.1    // Normalized Value: 0 - 1
distortion.rounding = 0.1      // Normalized Value: 0 - 1
distortion.decimationMix = 0.1 // Normalized Value: 0 - 1

//: Ring modulator parameters
distortion.ringModFreq1 = 100 // Hertz
distortion.ringModFreq2 = 100 // Hertz
distortion.ringModBalance = 0.5 // Normalized Value: 0 - 1
distortion.ringModMix = 0.5       // Normalized Value: 0 - 1


//: Polynomial parameters
distortion.linearTerm    = 0.5 // Normalized Value: 0 - 1
distortion.squaredTerm   = 0.5 // Normalized Value: 0 - 1
distortion.cubicTerm     = 0.5 // Normalized Value: 0 - 1
distortion.polynomialMix = 0.5 // Normalized Value: 0 - 1

//: Gain and mix parameters
distortion.softClipGain = -6 // dB
distortion.finalMix = 0.2    // Normalized Value: 0 - 1

AudioKit.output = distortion
AudioKit.start()
player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in

    if distortion.isBypassed {
        distortion.start()
    } else {
        distortion.bypass()
    }
    distortion.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
