//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Pink Noise
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let noise = AKPinkNoise(amplitude: 0.0)
audiokit.audioOutput = noise
audiokit.start()

let startTime = NSDate()

//: This is a timer that will change the amplitude of the pink noise
Timer.start(0.1, repeats: true) { (t: NSTimer) in
    let t = Float(NSDate().timeIntervalSinceDate(startTime))*100
    let amp = (1.0 - cos(t/100)) * 0.5 // Click the eye to see a graph view
    noise.amplitude = amp
}

//: View the timeline in the assistant page to see the live waveform
let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
