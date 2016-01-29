//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sequencer - Multiple output
//:
import XCPlayground
import AudioKit

//: Create the sequencer, but we can't init it until we do some basic setup
var seq:AKSequencer?

//: Create some samplers, load different sounds, and connect it to a mixer and the output
var sampler1 = AKSampler()
var sampler2 = AKSampler()
sampler1.loadEXS24("Sounds/sawPiano1")
sampler2.loadEXS24("Sounds/sqrTone1")

var mixer = AKMixer()
mixer.connect(sampler1)
mixer.connect(sampler2)
mixer.volume = 0.4
AudioKit.output = mixer

seq =//: Load in a midi file, and set the sequencer to the main audiokit engine
 AKSequencer(filename: "4tracks")

seq!.//: Do some basic setup to make the sequence loop correctly
setLength(4)
seq!.loopOn()
seq!.//: Here we set each alternating track to a different instrument
//: (Note that track 0 in our case is just meta information...not actual notes)
avTracks[1].destinationAudioUnit = sampler1.samplerUnit
seq!.avTracks[2].destinationAudioUnit = sampler2.samplerUnit
seq!.avTracks[3].destinationAudioUnit = sampler1.samplerUnit
seq!.avTracks[4].destinationAudioUnit = sampler2.samplerUnit

Audio//: Hear it go
Kit.start()
seq!.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
