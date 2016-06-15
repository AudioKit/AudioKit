//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Filter Section
//: ### This is where we created the filter for the Analog Synth X example project.
import PlaygroundSupport
import AudioKit

let bundle = Bundle.main()
let file = bundle.pathForResource("guitarloop", ofType: "wav")

//: Here we set up a player to the loop the file's playback
var player = AKAudioPlayer(file!)
player.looping = true

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

PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
