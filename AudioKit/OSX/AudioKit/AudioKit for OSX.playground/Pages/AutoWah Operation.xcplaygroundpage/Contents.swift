//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AutoWah Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "guitarloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { 
    let wahAmount = AKOperation.sineWave(frequency: 0.6).scale(minimum: 1, maximum: 0)
    return AKOperation.input.autoWah(wah: wahAmount, amplitude: 0.6)
}

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
