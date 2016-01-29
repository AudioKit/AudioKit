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
AudioKit.output = mixer

//: Load in a midi file, and set the sequencer to the main audiokit engine
seq = AKSequencer(filename: "4tracks", engine: AudioKit.engine)

//: Do some basic setup to make the sequence loop correctly
seq!.setLength(4)
seq!.loopOn()
//: Here we set each alternating track to a different instrument
//: (Note that track 0 in our case is just meta information...not actual notes)
seq!.avTracks[1].destinationAudioUnit = sampler1.samplerUnit
seq!.avTracks[2].destinationAudioUnit = sampler2.samplerUnit
seq!.avTracks[3].destinationAudioUnit = sampler1.samplerUnit
seq!.avTracks[4].destinationAudioUnit = sampler2.samplerUnit

//: Hear it go
AudioKit.start()
seq!.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
