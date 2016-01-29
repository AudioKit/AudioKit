//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Parametric Equalizer
//: #### A parametric equalizer can be used to raise or lower specific frequencies or frequency bands. Live sound engineers often use parametric equalizers during a concert in order to keep feedback from occuring, as they allow much more precise control over the frequency spectrum than other types of equalizers. Acoustic engineers will also use them to tune a room. This node may be useful if you're building an app to do audio analysis.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var parametricEQ = AKParametricEQ(player)

//: Set the parameters of the parametric equalizer here
parametricEQ.centerFrequency = 1000 // Hz
parametricEQ.q = 1 // Hz
parametricEQ.gain = 10 // dB

AudioKit.output = parametricEQ
AudioKit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
