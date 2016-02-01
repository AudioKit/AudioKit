//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Morphing Oscillator
//: ### Oscillator with four different waveforms built in
import XCPlayground
import AudioKit

//: Try changing the table type to triangle or another AKTableType
//: or changing the number of points to a smaller number (has to be a power of 2)
var morph = AKMorphingOscillator(waveformArray:[AKTable(.Sine), AKTable(.Triangle), AKTable(.Sawtooth), AKTable(.Square)])
morph.frequency = 400
morph.amplitude = 0.77
morph.index = 0.8

AudioKit.output = morph
AudioKit.start()
morph.start()

let plotView = AKOutputWaveformPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView

var t = 0.0
let timeStep = 0.1

AKPlaygroundLoop(every: timeStep) {
    morph.index = 1.5 * ( 1.0 + sin(t) )
    
    t = t + timeStep
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
