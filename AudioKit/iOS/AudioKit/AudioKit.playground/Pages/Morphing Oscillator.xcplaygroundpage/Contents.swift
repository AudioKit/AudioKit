//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Morphing Oscillator
//: ### Oscillator with four different waveforms built in
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Try changing the table type to triangle or another AKTableType
//: or changing the number of points to a smaller number (has to be a power of 2)
var morph = AKOscillator(waveform: AKTable(.Square))
morph.frequency = 400
morph.amplitude = 0.77
//morph.index = 0.25

audiokit.audioOutput = morph
audiokit.start()
morph.start()

let plotView = AKOutputWaveformPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView

AKPlaygroundLoop(every:3) {
//    morph.frequency = 900
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
