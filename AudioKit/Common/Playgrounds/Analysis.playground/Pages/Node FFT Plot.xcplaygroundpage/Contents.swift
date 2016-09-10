//: ## Node FFT Plot
//: An FFT plot displays a signal as relative amplitudes across the frequency spectrum.
//: This playground creates spikes in the plot by playing an oscillator at a specific frequency.
import XCPlayground
import AudioKit

var oscillator = AKOscillator(waveform: AKTable(.Sine, size: 4096))
var mixer = AKMixer(oscillator)

AudioKit.output = mixer
AudioKit.start()

oscillator.start()
var multiplier = 1.1

AKPlaygroundLoop(frequency: 10) {
    if oscillator.frequency > 10000 {
        oscillator.frequency = 10000
        multiplier = 0.9
    }

    if oscillator.frequency < 100 {
        oscillator.frequency = 100
        multiplier = 1.1
    }

    oscillator.frequency *= multiplier
    oscillator.amplitude = 0.2
}

let plot = AKNodeFFTPlot(mixer, frame: CGRect(x: 0, y: 0, width: 500, height: 500))
plot.shouldFill = true
plot.shouldMirror = false
plot.shouldCenterYAxis = false
plot.color = NSColor.purpleColor()

XCPlaygroundPage.currentPage.liveView = plot

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true