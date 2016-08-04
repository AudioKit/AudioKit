//: ## Output Waveform Plot
//: ### If you open the Assitant editor and make sure it shows the
//: ### "Output Waveform Plot.xcplaygroundpage (Timeline) view",
//: ### you should see a plot of the waveform in real time
import XCPlayground
import AudioKit

var fmOscillator = AKFMOscillator(waveform: AKTable(.Sine))
AudioKit.output = fmOscillator
AudioKit.start()

AKPlaygroundLoop(frequency: 1) {
    fmOscillator.baseFrequency = random(220, 880)
    fmOscillator.carrierMultiplier = random(0, 4)
    fmOscillator.modulationIndex = random(0, 5)
    fmOscillator.modulatingMultiplier = random(0, 0.3)
    fmOscillator.amplitude = random(0.4, 0.7)
    fmOscillator.start()
}

let plotView = AKOutputWaveformPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true