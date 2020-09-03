//: ## Filter Section
//: This playgrounds was the development area for the filter in the Analog Synth X example project.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

// Filter Properties
var cutoffFrequency = 1_100
var resonance = 0.9
var filterMix = 0.9

// LFO Properties
var lfoAmplitude = 1_000
var lfoRate = 1.0 / 3.428

let filterSectionEffect = AKOperationEffect(player) { player in
    let lfo = AKOperation.sineWave(frequency: lfoRate, amplitude: lfoAmplitude)
    return player.moogLadderFilter(cutoffFrequency: lfo + cutoffFrequency,
                                   resonance: resonance)
}
engine.output = filterSectionEffect
try engine.start()

player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
