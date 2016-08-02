//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Clip Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, _ in
    let sinusoid = AKOperation.sineWave(frequency: 0.3)
    let limitSine = sinusoid.scale(minimum: 0, maximum: 1)
    return player.clip(limitSine)
}

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
