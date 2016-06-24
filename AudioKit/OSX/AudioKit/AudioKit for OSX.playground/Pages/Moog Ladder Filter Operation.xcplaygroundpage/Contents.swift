//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Moog Ladder Filter Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "leadloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let frequency = AKOperation.sineWave(frequency: 1).scale(minimum: 500, maximum: 1000)
let resonance = abs(AKOperation.sineWave(frequency: 0.3)) * 0.95

let filter  = AKOperation.input.moogLadderFilter(cutoffFrequency: frequency, resonance: resonance) * 3

let effect = AKOperationEffect(player, operation: filter)

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
