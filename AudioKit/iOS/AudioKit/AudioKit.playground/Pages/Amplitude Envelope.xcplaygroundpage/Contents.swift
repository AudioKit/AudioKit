//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Amplitude Envelope
//: ### Enveloping an FM Oscillator with an ADSR envelope
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Try changing the table type to triangle or another AKTableType
//: or changing the number of points to a smaller number (has to be a power of 2)
var fm = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))

var fmWithADSR = AKAmplitudeEnvelope(fm, attackDuration: 0.1, decayDuration: 0.3, sustainLevel: 0.8, releaseDuration: 1.0)

audiokit.audioOutput = fmWithADSR
audiokit.start()

fm.start()
fmWithADSR.start()

AKPlaygroundLoop(every:1) {
    if fmWithADSR.isStarted {
        fmWithADSR.stop()
    } else {
        fm.baseFrequency = random(220, 880)
        fmWithADSR.start()
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
