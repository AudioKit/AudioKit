//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Variable Delay Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true


let time = AKOperation.sineWave(frequency: 0.3).scale(minimum: 0.01, maximum: 0.2)
let feedback = AKOperation.sineWave(frequency: 0.21).scale(minimum: 0.5, maximum: 0.9)

let variableDelay = AKOperation.input.variableDelay(time: time, feedback: feedback, maximumDelayTime: 1.0)
let effect = AKOperationEffect(player, operation: variableDelay)

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
