//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Audio Plotting
//: ### If you open the Assitant editor and make sure it shows the Output Waveform Plot.xcplaygroundpage (Timeline) view, you should see a plot of the waveform in real time
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

var fm = AKFMOscillator(table: AKTable(.Sine, size: 4096))
audiokit.audioOutput = fm
audiokit.start()

let updater = AKPlaygroundLoop(frequency: 5) {
    fm.baseFrequency.randomize(220, 880)
    fm.carrierMultiplier.randomize(0, 4)
    fm.modulationIndex.randomize(0, 5)
    fm.modulatingMultiplier.randomize(0, 0.3)
    fm.amplitude.randomize(0, 0.7)
}

let plotView = AKOutputWaveformPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
