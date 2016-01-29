//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## High Pass Filter
//: ### A high-pass filter takes an audio signal as an input, and cuts out the low-frequency components of the audio signal, allowing for the higher frequency components to "pass through" the filter.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var highPassFilter = AKHighPassFilter(player)

//: Set the parameters of the High-Pass Filter here
highPassFilter.cutoffFrequency = 1000 // Hz
highPassFilter.resonance = 10 // dB

AudioKit.output = highPassFilter
AudioKit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if highPassFilter.isBypassed {
        highPassFilter.start()
    } else {
        highPassFilter.bypass()
    }
    highPassFilter.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
