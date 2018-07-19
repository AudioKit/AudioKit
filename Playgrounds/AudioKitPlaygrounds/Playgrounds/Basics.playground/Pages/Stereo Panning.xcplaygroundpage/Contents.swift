//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Stereo Panning
//: Panning is a basic operation that is essential to mixing and direction
//: perception and it couldn't be easier with AKPanner.
import AudioKitPlaygrounds
import AudioKit

//: Set up the audio player
let file = try AKAudioFile(readFileName: "drumloop.wav")

let player = AKPlayer(audioFile: file)
player.isLooping = true

//: Route the audio player through the panner
var panner = AKPanner(player)

//: Adjust the pan to smoothly cycle left and right over time
var time = 0.0
let timeStep = 0.05
let timer = AKPeriodicFunction(every: timeStep) {
    panner.pan = sin(time)
    time += timeStep
}

AudioKit.output = panner
try AudioKit.start(withPeriodicFunctions: timer)

player.play()
timer.start()
timer.sporth

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
