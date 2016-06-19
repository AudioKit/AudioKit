//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## iOS-only Reverb
//: ### For some reason, this reverb is only supplied on iOS devices. It is super-powerful.

import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingFileName: "drumloop", withExtension: "wav", fromBaseDirectory: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var reverb2 = AKReverb2(player)

//: Set the parameters here
reverb2.dryWetMix = 1 // CrossFade
reverb2.gain = 0 // Decibels
reverb2.minDelayTime = 0.008 // Secs
reverb2.maxDelayTime = 0.050 // Secs
reverb2.decayTimeAt0Hz = 3.0 // Secs
reverb2.decayTimeAtNyquist = 0.5 // Secs
reverb2.randomizeReflections = 0 // Integer

AudioKit.output = reverb2
AudioKit.start()

player.play()

//: Toggle processing on every loop
AKPlaygroundLoop(every: 3.428) { () -> () in
    if reverb2.isBypassed {
        reverb2.start()
    } else {
        reverb2.bypass()
    }
    reverb2.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
