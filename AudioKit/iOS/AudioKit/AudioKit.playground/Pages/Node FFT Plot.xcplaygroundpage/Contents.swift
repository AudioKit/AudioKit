//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Node FFT Plot
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

var oscillator = AKOscillator(table: AKTable(.Sine, size: 4096))
var mixer = AKMixer(oscillator)
audiokit.audioOutput = mixer
audiokit.start()

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
