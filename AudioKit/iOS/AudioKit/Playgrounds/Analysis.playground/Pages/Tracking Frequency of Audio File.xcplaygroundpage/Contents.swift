//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tracking Frequency of an Audio File
//: ### Here is a more real-world example of tracking the pitch of an audio stream
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "leadloop.wav", baseDir: .Resources)

var player = try AKAudioPlayer(file: file)
player.looping = true

let tracker = AKFrequencyTracker(player)

AudioKit.output = tracker
AudioKit.start()
player.play()

AKPlaygroundLoop(every: 0.1) {
    let amp = tracker.amplitude
    let freq = tracker.frequency
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
