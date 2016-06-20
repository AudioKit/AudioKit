//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Filter Section
//: ### This is where we created the filter for the Analog Synth X example project.
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "guitarloop", andExtension: "wav", fromBaseDirectory: .Resources)


//: Here we set up a player to the loop the file's playback
let player = try AKAudioPlayer(file: file)
player.looping = true

//: The amplitude tracker's passes its input to the output, so we can insert into the signal chain at the bottom
// Filter Properties
var cutoffFrequency = 1100
var resonance = 0.9
var filterMix = 0.9

// LFO Properties
var lfoAmplitude = 1000
var lfoRate = 1.0 / 3.428

let lfo = AKOperation.sineWave(frequency: lfoRate, amplitude: lfoAmplitude)
let moog = AKOperation.input.moogLadderFilter(cutoffFrequency: lfo + cutoffFrequency, resonance: resonance)
let filterSectionEffect = AKOperationEffect(player, operation: moog)

AudioKit.output = filterSectionEffect
AudioKit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
