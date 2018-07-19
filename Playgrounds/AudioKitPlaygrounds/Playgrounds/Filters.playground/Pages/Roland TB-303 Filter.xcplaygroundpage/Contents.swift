//: ## Roland TB-303 Filter
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = AKPlayer(audioFile: file)
player.isLooping = true

var filter = AKRolandTB303Filter(player)
filter.cutoffFrequency = 1_350
filter.resonance = 0.8

AudioKit.output = filter
try AudioKit.start()
player.play()

var time = 0.0
let timeStep = 0.02
let hz = 2.0

AKPlaygroundLoop(every: timeStep) {
    filter.cutoffFrequency = (1.0 - cos(2 * 3.14 * hz * time)) * 600 + 700
    time += timeStep
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
