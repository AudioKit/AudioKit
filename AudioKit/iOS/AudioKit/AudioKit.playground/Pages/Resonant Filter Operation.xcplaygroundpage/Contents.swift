//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Resonant Filter Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "guitarloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let frequency = AKOperation.sineWave(frequency: 0.5).scale(minimum: 2000, maximum: 5000)
let bandwidth = abs(AKOperation.sineWave(frequency: 0.3)) * 1000

let filter  = AKOperation.input.resonantFilter(frequency: frequency, bandwidth: bandwidth) * 0.1

let effect = AKOperationEffect(player, operation: filter)

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
