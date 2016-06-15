//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Node FFT Plot
//: ### You can also do spectral analysis of your signal by looking at FFT Plot. Here we create spikes in the plot by randomly playing an osccilator at a specific frequency.
import PlaygroundSupport
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

let plot = AKNodeFFTPlot(mixer, frame: CGRect(x: 0, y: 0, width: 500, height: 500))
plot.shouldFill = true
plot.shouldMirror = false
plot.shouldCenterYAxis = false
plot.color = UIColor.purpleColor()

PlaygroundPage.current.liveView = plot

PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
