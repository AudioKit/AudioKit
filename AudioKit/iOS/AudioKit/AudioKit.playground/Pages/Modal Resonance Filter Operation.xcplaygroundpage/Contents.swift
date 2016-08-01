//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Modal Resonance Filter Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let frequency = AKOperation.sineWave(frequency: 0.3).scale(minimum: 200, maximum: 1200)

let effect = AKOperationEffect(player) { player, _ in
    return player.modalResonanceFilter(frequency: frequency,
                                       qualityFactor: 50) * 0.2
}

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
