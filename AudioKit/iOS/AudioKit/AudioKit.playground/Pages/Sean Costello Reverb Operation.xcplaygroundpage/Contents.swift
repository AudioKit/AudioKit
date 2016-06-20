//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sean Costello Reverb Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "mixloop", andExtension: "wav", fromBaseDirectory: .Resources)

//: Here we set up a player to the loop the file's playback
var player = try AKAudioPlayer(file: file)
player.looping = true

let reverb = AKOperation.input.reverberateWithCostello(
    feedback: AKOperation.sineWave(frequency: 0.1).scale(minimum: 0.5, maximum: 0.97),
    cutoffFrequency: 10000)
let effect = AKOperationEffect(player, stereoOperation: reverb)

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
