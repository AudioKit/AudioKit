//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Variable Delay Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)

var player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, _ in
    let time = AKOperation.sineWave(frequency: 0.3).scale(minimum: 0.01, maximum: 0.2)
    let feedback = AKOperation.sineWave(frequency: 0.21).scale(minimum: 0.5, maximum: 0.9)
    return player.variableDelay(time: time,
                                feedback: feedback,
                                maximumDelayTime: 1.0)
}

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
