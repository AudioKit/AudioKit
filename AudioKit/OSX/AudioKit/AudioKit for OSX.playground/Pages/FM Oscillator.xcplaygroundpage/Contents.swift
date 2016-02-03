//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FM Oscillator
//: 
import XCPlayground
import AudioKit

//: Try changing the table type to triangle or another AKTableType
//: or changing the number of points to a smaller number (has to be a power of 2)
var fm = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))
fm.amplitude = 0
AudioKit.output = fm
AudioKit.start()

fm.start()

AKPlaygroundLoop(frequency: 5) {
    fm.baseFrequency = random(220, 880)
    fm.carrierMultiplier = random(0, 4)
    fm.modulationIndex = random(0, 5)
    fm.modulatingMultiplier = random(0, 0.3)
    fm.ramp(amplitude: random(0, 0.3))
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
