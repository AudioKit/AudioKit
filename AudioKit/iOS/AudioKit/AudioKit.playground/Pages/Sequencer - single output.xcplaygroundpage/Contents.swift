//: [Previous](@previous)
import XCPlayground
import AudioKit


let audiokit = AKManager.sharedInstance

//: Create the sequencer, but we can't init it until we do some basic setup
var seq:AKSequencer?

//: Create a sampler, load a sound, and connect it to the output
//var sampler = AKSampler()
var inst = AKMidiInstrument()
var mixer = AKMixer()

//sampler.loadEXS24("Sounds/sawPiano1")
audiokit.engine.connect(inst, to: audiokit.engine.outputNode, format: AKManager.format)
//audiokit.audioOutput = inst as? AKNode
//mixer.connect(inst.node)

//: Load in a midi file, and set the sequencer to the main audiokit engine
seq = AKSequencer(filename: "4tracks", engine: audiokit.engine)

//: Do some basic setup to make the sequence loop correctly
seq!.setLength(4)
seq!.loopOn()

//: Here we set all tracks of the sequencer to the same audioUnit
seq!.setGlobalAVAudioUnitOutput(inst)

//: Hear it go
audiokit.start()
seq!.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [Next](@next)
