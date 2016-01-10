//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phase-Locked Vocoder
//: ### A different kind of time and pitch stretching 
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let url = bundle.URLForResource("guitarloop", withExtension: "wav")
let phaseLockedVocoder = AKPhaseLockedVocoder(audioFileURL: url!)

audiokit.audioOutput = phaseLockedVocoder
audiokit.start()
phaseLockedVocoder.start()
phaseLockedVocoder.amplitude = 1
phaseLockedVocoder.pitchRatio = 1

var increment = 0.1

AKPlaygroundLoop(every: 0.1) {
    if phaseLockedVocoder.isPlaying {
        phaseLockedVocoder.position
        phaseLockedVocoder.pitchRatio = 1//[0.75,0.85,1.1,1.2].randomElement()
        phaseLockedVocoder.position = phaseLockedVocoder.position + increment
        if phaseLockedVocoder.position > 3.4 && increment > 0 { increment = -random(0.05, 0.3) }
        if phaseLockedVocoder.position < 0.01 && increment < 0 { increment = random(0.1,  0.3) }
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
