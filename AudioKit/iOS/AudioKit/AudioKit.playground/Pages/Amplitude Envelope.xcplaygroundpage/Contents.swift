//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Amplitude Envelope
//: ### Enveloping an FM Oscillator with an ADSR envelope
import XCPlayground
import AudioKit

//: Try changing the table type to triangle or another AKTableType
//: or changing the number of points to a smaller number (has to be a power of 2)
var fm = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))

var fmWithADSR = AKAmplitudeEnvelope(fm, attackDuration: 0.1, decayDuration: 0.3, sustainLevel: 0.8, releaseDuration: 1.0)

AudioKit.output = fmWithADSR
AudioKit.start()

fm.start()
fmWithADSR.start()

AKPlaygroundLoop(every:1) {
    if fmWithADSR.isStarted {
        fmWithADSR.stop()
    } else {
        fm.baseFrequency = random(220, 880)
        fmWithADSR.attackDuration = random(0.01, 0.5)
        fmWithADSR.decayDuration = random(0.01, 0.2)
        fmWithADSR.sustainLevel = random(0.01, 1)
        fmWithADSR.releaseDuration = random(0.01, 1)
        fmWithADSR.start()
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
