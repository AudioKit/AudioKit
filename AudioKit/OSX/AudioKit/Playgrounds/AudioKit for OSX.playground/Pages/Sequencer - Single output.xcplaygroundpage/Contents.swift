//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sequencer - Single output
//:
import XCPlayground
import AudioKit

//: Create the sequencer, but we can't init it until we do some basic setup
var seq:AKSequencer?

//: Create a sampler, load a sound, and connect it to the output
var sampler = AKSampler()

sampler.loadEXS24("Sounds/sawPiano1")
AudioKit.output = sampler

seq =//: Load in a midi file, and set the sequencer to the main audiokit engine
 AKSequencer(filename: "4tracks", engine: AudioKit.engine)

seq!.//: Do some basic setup to make the sequence loop correctly
setLength(4)
seq!.loopOn()

seq!.//: Here we set all tracks of the sequencer to the same audioUnit
setGlobalAVAudioUnitOutput(sampler.samplerUnit)

Audio//: Hear it go
Kit.start()
seq!.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
