//: ## AutoWah Operation
//:
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, _ in
    let wahAmount = AKOperation.sineWave(frequency: 0.6).scale(minimum: 1, maximum: 0)
    return player.autoWah(wah: wahAmount, amplitude: 0.6)
}

AudioKit.output = effect
AudioKit.start()
player.play()

PlaygroundPage.current.needsIndefiniteExecution = true