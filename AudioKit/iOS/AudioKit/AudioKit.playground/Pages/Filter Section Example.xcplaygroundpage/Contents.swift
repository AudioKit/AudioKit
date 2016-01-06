//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Fattening Effect Playground
//: ### Needed to test this for the keyboard project
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")

//: Here we set up a player to the loop the file's playback
var player = AKAudioPlayer(file!)
player.looping = true

// Filter Properties
var cutoffFrequency = 1000
var resonance = 0.9
var filterMix = 0.9

// LFO Properties
var lfoAmplitude = 1000
var lfoRate = 1.0 / 3.428
var lfoMix = 1.0

let lfo = AKOperation.sawtooth(frequency: lfoRate, amplitude: lfoAmplitude * lfoMix)
let moog = AKOperation.input.moogLadderFilter(cutoffFrequency: lfo + cutoffFrequency, resonance: resonance)
let mixed = mix(AKOperation.input, moog, t: filterMix)
let filterSectionEffect = AKOperationEffect(player, operation: mixed)


audiokit.audioOutput = filterSectionEffect
audiokit.start()

player.play()


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)



