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
var fmOscillator = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))
fm.amplitude = 0
AudioKit.output = fmOscillator
AudioKit.start()

fm.start()

AKPlaygroundLoop(frequency: 5) {
    fmOscillator.baseFrequency        = random(220, 880)
    fmOscillator.carrierMultiplier    = random(0, 4)
    fmOscillator.modulationIndex      = random(0, 5)
    fmOscillator.modulatingMultiplier = random(0, 0.3)
    fmOscillator.ramp(amplitude:        random(0, 0.3))
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
