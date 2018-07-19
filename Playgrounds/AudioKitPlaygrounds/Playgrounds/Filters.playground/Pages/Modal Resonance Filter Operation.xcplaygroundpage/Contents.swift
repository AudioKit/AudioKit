//: ## Modal Resonance Filter Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = AKPlayer(audioFile: file)
player.isLooping = true

let frequency = AKOperation.sineWave(frequency: 0.3).scale(minimum: 200, maximum: 1_200)

let effect = AKOperationEffect(player) { player, _ in
    return player.modalResonanceFilter(frequency: frequency, qualityFactor: 50) * 0.2
}

AudioKit.output = effect
try AudioKit.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
