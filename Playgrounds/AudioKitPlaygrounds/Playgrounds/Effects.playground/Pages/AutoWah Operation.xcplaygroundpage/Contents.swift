//: ## AutoWah Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = AKPlayer(audioFile: file)
player.isLooping = true

let effect = AKOperationEffect(player) { player, _ in
    let wahAmount = AKOperation.sineWave(frequency: 0.6).scale(minimum: 1, maximum: 0)
    return player.autoWah(wah: wahAmount, amplitude: 0.6)
}

AudioKit.output = effect
try AudioKit.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
