//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Node FFT Plot
//: ### You can also do spectral analysis of your signal by looking at FFT Plot. Here we create spikes in the plot by randomly playing an osccilator at a specific frequency.
import XCPlayground
import AudioKit

var oscillator = AKOscillator(waveform: AKTable(.Sine, size: 4096))
var mixer = AKMixer(oscillator)

AudioKit.output = mixer
AudioKit.start()

oscillator.start()

AKPlaygroundLoop(frequency: 5) {
    oscillator.frequency = random(220, 20000)
    oscillator.amplitude = 0.2
}


let plot = AKNodeFFTPlot(mixer)
plot.plot?.shouldFill = true
plot.plot?.shouldMirror = false
plot.plot?.shouldCenterYAxis = false
plot.plot?.color = UIColor.purpleColor()
let view = plot.containerView

XCPlaygroundPage.currentPage.liveView = plot.containerView

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
