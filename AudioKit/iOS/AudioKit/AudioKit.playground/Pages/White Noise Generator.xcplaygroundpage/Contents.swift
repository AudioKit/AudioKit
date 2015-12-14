//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## White Noise
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let noise = AKWhiteNoise(amplitude: 0.0)
audiokit.audioOutput = noise
audiokit.start()

//: This is a timer that will change the amplitude of the pink noise
var t = 0.0
let step = 0.02

let updater = AKPlaygroundLoop(every: step) {
    let amp = (1.0 - cos(2*t)) * 0.5 // Click the eye to see a graph view
    noise.amplitude = Float(amp)
    t = t + step
}

//: View the timeline in the assistant page to see the live waveform
let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
