//: ## Roland TB-303 Filter
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKRolandTB303Filter(player)
filter.cutoffFrequency = 1350
filter.resonance = 0.8

AudioKit.output = filter
AudioKit.start()
player.play()


var time = 0.0
let timeStep = 0.02

AKPlaygroundLoop(every: timeStep) {

    let hz = 2.0
    filter.cutoffFrequency = (1.0 - cos(2 * 3.14 * hz * time)) * 600 + 700
    time += timeStep
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
