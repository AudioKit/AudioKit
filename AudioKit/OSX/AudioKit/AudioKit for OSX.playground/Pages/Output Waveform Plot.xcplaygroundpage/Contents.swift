//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Output Waveform Plot
//: ### If you open the Assitant editor and make sure it shows the Output Waveform Plot.xcplaygroundpage (Timeline) view, you should see a plot of the waveform in real time
import XCPlayground
import AudioKit

var fm = AKFMOscillator(
    waveform: AKTable(.Sine, size: 4096))
AudioKit.output = fm
AudioKit.start()

AKPlaygroundLoop(frequency: 1) {
    fm.baseFrequency = random(220, 880)
    fm.carrierMultiplier = random(0, 4)
    fm.modulationIndex = random(0, 5)
    fm.modulatingMultiplier = random(0, 0.3)
    fm.ramp(amplitude: random(0.4, 0.7))
    fm.start()
}

let plotView = AKOutputWaveformPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
