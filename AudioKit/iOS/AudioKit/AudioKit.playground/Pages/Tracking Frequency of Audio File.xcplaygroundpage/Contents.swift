//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tracking Frequency of an Audio File
//: ### Here is a more real-world example of tracking the pitch of an audio stream
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "leadloop", andExtension: "wav", fromBaseDirectory: .Resources)

//: Here we set up a player to the loop the file's playback
var player = try AKAudioPlayer(file: file)
player.looping = true

let tracker = AKFrequencyTracker(player, minimumFrequency: 400, maximumFrequency: 600)

AudioKit.output = tracker
AudioKit.start()
player.play()

//: And here's where we monitor the results of tracking the amplitude.
AKPlaygroundLoop(every: 0.1) {
    let amp = tracker.amplitude
    let freq = tracker.frequency
}

//: This keeps the playground running so that audio can play for a long time
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
