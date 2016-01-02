//: [Previous](@previous)

/* in progress - dealing with sequencer
import XCPlayground
import AudioKit


let audiokit = AKManager.sharedInstance

//: Create the sequencer, but we can't init it until we do some basic setup
var seq:AKSequencer?

//: Create a sampler, load a sound, and connect it to the output
var sampler = AKSampler()

sampler.loadEXS24("Sounds/sawPiano1")
audiokit.audioOutput = sampler

//: Load in a midi file, and set the sequencer to the main audiokit engine
seq = AKSequencer(filename: "4tracks", engine: audiokit.engine)

//: Do some basic setup to make the sequence loop correctly
seq!.setLength(4)
seq!.loopOn()

//: Here we set all tracks of the sequencer to the same audioUnit
seq!.setGlobalAVAudioUnitOutput(sampler.samplerUnit)

//: Hear it go
audiokit.start()
seq!.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
*/
//: [Next](@next)
