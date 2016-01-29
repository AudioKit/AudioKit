//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Dry Wet Mixer
//: ### It's a very common operation to mix exactly two inputs, one before processing occurs, and one after, and then mixing down to a combination of the two.  This is so common that most of the AudioKit nodes have a dry/wet mix parameter built in.  But, if you are building your own custom effects, or making a long chain of effects, you can use AKDryWetMixer to blend your signals.
import XCPlayground
import AudioKit

//: This section prepares the players
let bundle = NSBundle.mainBundle()
let drumFile   = bundle.pathForResource("drumloop",   ofType: "wav")
var drums  = AKAudioPlayer(drumFile!)
drums.looping  = true

//: Let's build a chain:

var delay = AKDelay(drums)
delay.time = 0.1
delay.feedback = 0.8
let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.LargeChamber)

//: Now let's mix the result of those two processors back with the original

let mixture = AKDryWetMixer(drums, reverb, balance: 0.5)

AudioKit.output = mixture
AudioKit.start()
drums.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
