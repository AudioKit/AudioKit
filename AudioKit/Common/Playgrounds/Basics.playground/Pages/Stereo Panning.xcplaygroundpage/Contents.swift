//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Stereo Panning
//: Panning is a basic operation that is essential to mixing and direction
//: perception and it couldn't be easier with AKPanner.

import AudioKit

//: Set up the audio player
let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

//: Route the audio player through the panner
var panner = AKPanner(player)

AudioKit.output = panner
AudioKit.start()

player.play()

//: Adjust the pan to smoothly cycle left and right over time

var time = 0.0
let timeStep = 0.05
AKPlaygroundLoop(every: timeStep) {
    panner.pan
    panner.pan = sin(time)
    time += timeStep
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
