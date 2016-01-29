//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Auto Wah Wah
//: ### One of the most iconic guitar effects is the wah-pedal. Here, we run an audio loop of a guitar through an AKAutoWah node. 
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var wah = AKAutoWah(player)

//: Set the parameters of the auto-wah here
wah.wah = 1
wah.amplitude = 1

AudioKit.output = wah
AudioKit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
