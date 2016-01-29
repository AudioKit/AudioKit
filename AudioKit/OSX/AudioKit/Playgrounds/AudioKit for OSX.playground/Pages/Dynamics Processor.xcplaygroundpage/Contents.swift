//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Dynamics Processor
//: ### The AKDynamicsProcessor is both a compressor and an expander based on apple's Dynamics Processor audio unit. threshold and headRoom (similar to 'ratio' you might be more familiar with) are specific to the compressor, expansionRatio and expansionThreshold control the expander.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var fmChord = AKFMSynth(voiceCount: 2)
var mix = AKMixer()
var dynamicsProcessor = AKDynamicsProcessor(mix)

//: Set the parameters of the dynamics processor here
dynamicsProcessor.threshold = -20 // dB
dynamicsProcessor.headRoom = 0.1 // dB - similar to 'ratio' on most compressors
dynamicsProcessor.attackTime = 0.01 // secs
dynamicsProcessor.releaseTime = 0.25 // secs
dynamicsProcessor.expansionRatio = 1 // effectively bypassing the expansion by using ratio of 1
dynamicsProcessor.expansionThreshold = 0 // rate
dynamicsProcessor.masterGain = 20 // dB - makeup gain

mix.connect(fmChord)
mix.connect(player)

AudioKit.output = dynamicsProcessor
AudioKit.start()

player.play()
fmChord.playNote(55, velocity: 100)
fmChord.playNote(48, velocity: 100)
fmChord.amplitude = 0.04            //set the fm volume low to hear the compressor pumping
fmChord.modulationIndex = 2.02

//: Toggle processing on every loop

AKPlaygroundLoop(every: 3.428) { () -> () in
    if dynamicsProcessor.isBypassed {
        dynamicsProcessor.start()
    } else {
        dynamicsProcessor.bypass()
    }
    dynamicsProcessor.isBypassed ? "Bypassed" : "Processing" // Open Quicklook for this
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
