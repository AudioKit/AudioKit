//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tracking Amplitude
//: ### Tracking the amplitude of one node's output using the AKAmplitudeTracker node.

//: Standard imports and AudioKit setup:
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("leadloop", ofType: "wav")

var player = AKAudioPlayer(file!)
player.looping = true

//: The amplitude tracker's passes its input to the output, so we can insert into the signal chain at the bottom
audiokit.audioOutput = player
audiokit.start()
player.play()
let fft = AKFFT(player)

//: And here's where we monitor the results of tracking the amplitude.
let updater = AKPlaygroundLoop(every: 0.1) {
    let max = fft.fftData.maxElement()!
    let index = fft.fftData.indexOf(max)
}

//: This keeps the playground running so that audio can play for a long time
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: You can experiment with this playground by changing the volume function to a phasor or another well-known function to see how well the amplitude tracker can track.  Also, you could change the sound source from an oscillator to a noise generator, or any constant sound source (some things like a physical model would not work because the output has an envelope to its volume).  Instead of just plotting our results, we could use the value to drive other sounds or update an app's user interface.

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
