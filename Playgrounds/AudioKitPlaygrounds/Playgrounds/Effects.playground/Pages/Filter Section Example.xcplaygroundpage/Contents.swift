//: ## Filter Section
//: This playgrounds was the development area for the filter in the Analog Synth X example project.

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

// Filter Properties
var cutoffFrequency = 1_100
var resonance = 0.9
var filterMix = 0.9

// LFO Properties
var lfoAmplitude = 1_000
var lfoRate = 1.0 / 3.428

let filterSectionEffect = OperationEffect(player) { player in
    let lfo = Operation.sineWave(frequency: lfoRate, amplitude: lfoAmplitude)
    return player.moogLadderFilter(cutoffFrequency: lfo + cutoffFrequency,
                                   resonance: resonance)
}
engine.output = filterSectionEffect
try engine.start()

player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
