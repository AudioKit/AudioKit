//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Pass Filter
//: ### A low-pass filter takes an audio signal as an input, and cuts out the high-frequency components of the audio signal, allowing for the lower     frequency components to "pass through" the filter.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var lowPassFilter = AKLowPassFilter(player)

//: Set the parameters of the Low-Pass Filter here
lowPassFilter.cutoffFrequency = 1000 // Hz
lowPassFilter.resonance = 0 // dB

AudioKit.output = lowPassFilter
AudioKit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if lowPassFilter.isBypassed {
        lowPassFilter.start()
    } else {
        lowPassFilter.bypass()
    }
    lowPassFilter.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
