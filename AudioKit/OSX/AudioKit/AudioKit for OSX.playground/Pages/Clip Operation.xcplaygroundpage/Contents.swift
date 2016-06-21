//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Clip Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "mixloop", andExtension: "wav", fromBaseDirectory: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let sinusoid = AKOperation.sineWave(frequency: 0.3)
let limitSine = sinusoid.scale(minimum: 0, maximum: 1)

let clip = AKOperation.input.clip(limitSine)

let effect = AKOperationEffect(player, operation: clip)

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@nex