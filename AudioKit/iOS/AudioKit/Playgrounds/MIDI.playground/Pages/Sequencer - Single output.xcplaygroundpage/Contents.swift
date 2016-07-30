//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sequencer - Single output
//:
import XCPlayground
import AudioKit

//: Create the sequencer, but we can't init it until we do some basic setup
var sequencer: AKSequencer

//: Create a sampler, load a sound, and connect it to the output
var sampler = AKSampler()

sampler.loadWav("Sounds/fmpia1")

let reverb = AKCostelloReverb(sampler)

AudioKit.output = reverb

//: Load in a midi file, and set the sequencer to the main audiokit engine
sequencer = AKSequencer(filename: "4tracks", engine: AudioKit.engine)

//: Do some basic setup to make the sequence loop correctly
sequencer.setLength(AKDuration(beats: 4))
sequencer.enableLooping()

//: Set all tracks of the sequencer to the same audioUnit
sequencer.setGlobalAVAudioUnitOutput(sampler.samplerUnit)

//: Hear it go
AudioKit.start()
sequencer.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
