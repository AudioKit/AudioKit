//: ## Roland TB-303 Filter
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

var filter = RolandTB303Filter(player)
filter.cutoffFrequency = 1_350
filter.resonance = 0.8

engine.output = filter
try engine.start()
player.play()

var time = 0.0
let timeStep = 0.02
let hz = 2.0

PlaygroundLoop(every: timeStep) {
    filter.cutoffFrequency = (1.0 - cos(2 * 3.14 * hz * time)) * 600 + 700
    time += timeStep
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
