//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Mixing Nodes
//: ### So, what about connecting two operations to the output instead of feeding operations into each other in sequential order? To do that, you'll need a mixer.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: This section prepares the players
let bundle = NSBundle.mainBundle()
let drumFile   = bundle.pathForResource("drumloop",   ofType: "wav")
let bassFile   = bundle.pathForResource("bassloop",   ofType: "wav")
let guitarFile = bundle.pathForResource("guitarloop", ofType: "wav")
let leadFile   = bundle.pathForResource("leadloop",   ofType: "wav")

let drums  = AKAudioPlayer(drumFile!)
let bass   = AKAudioPlayer(bassFile!)
let guitar = AKAudioPlayer(guitarFile!)
let lead   = AKAudioPlayer(leadFile!)

drums.looping  = true
bass.looping   = true
guitar.looping = true
lead.looping   = true

//: Any number of inputs can be summed into one output
let mixer = AKMixer(drums, bass, guitar, lead)

audiokit.audioOutput = mixer
audiokit.start()

drums.play()
bass.play()
guitar.play()
lead.play()

//: Adjust the individual track volumes here
drums.volume  = 0.9
bass.volume   = 0.9
guitar.volume = 0.8
lead.volume   = 0.7

drums.pan  = 0.0
bass.pan   = 0.0
guitar.pan = 0.2
lead.pan   = -0.2

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
