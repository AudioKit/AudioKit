//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Output Waveform Plot
//: ### If you open the Assitant editor and make sure it shows the Output Waveform Plot.xcplaygroundpage (Timeline) view, you should see a plot of the waveform in real time
import PlaygroundSupport
import AudioKit

var fmOscillator = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))
AudioKit.output = fmOscillator
AudioKit.start()

fmOscillator.start()

AKPlaygroundLoop(frequency: 1.0) {
    fmOscillator.baseFrequency        = random(220, 880)
    fmOscillator.carrierMultiplier    = random(0, 4)
    fmOscillator.modulationIndex      = random(0, 5)
    fmOscillator.modulatingMultiplier = random(0, 0.3)
    fmOscillator.amplitude            = random(0.4, 0.7)
}

let plotView = AKOutputWaveformPlot.createView()
PlaygroundPage.current.liveView = plotView

PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
