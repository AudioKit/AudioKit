//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phase-Locked Vocoder
//: ### A different kind of time and pitch stretching 
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "guitarloop.wav", baseDir: .Resources)
let phaseLockedVocoder = AKPhaseLockedVocoder(file: file)

AudioKit.output = phaseLockedVocoder
AudioKit.start()
phaseLockedVocoder.start()
phaseLockedVocoder.amplitude = 1
phaseLockedVocoder.pitchRatio = 1
phaseLockedVocoder.rampTime = 0.1

var timeStep = 0.1

AKPlaygroundLoop(every: timeStep) {
    phaseLockedVocoder.position
    phaseLockedVocoder.pitchRatio = [0.75, 0.85, 1.1, 1.2].randomElement()
    phaseLockedVocoder.position = phaseLockedVocoder.position + timeStep
    if phaseLockedVocoder.position > 3.4 && timeStep > 0 { timeStep = -random(0.05, 0.3) }
    if phaseLockedVocoder.position < 0.01 && timeStep < 0 { timeStep = random(0.1, 0.3) }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
