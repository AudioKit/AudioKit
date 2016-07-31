//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Filter Section
//: ### This playgrounds was the development area for the filter in the Analog Synth X example project.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)


let player = try AKAudioPlayer(file: file)
player.looping = true

// Filter Properties
var cutoffFrequency = 1100
var resonance = 0.9
var filterMix = 0.9

// LFO Properties
var lfoAmplitude = 1000
var lfoRate = 1.0 / 3.428

let filterSectionEffect = AKOperationEffect(player) { player, _ in
    let lfo = AKOperation.sineWave(frequency: lfoRate, amplitude: lfoAmplitude)
    return player.moogLadderFilter(cutoffFrequency: lfo + cutoffFrequency,
                                   resonance: resonance)
}
AudioKit.output = filterSectionEffect
AudioKit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
