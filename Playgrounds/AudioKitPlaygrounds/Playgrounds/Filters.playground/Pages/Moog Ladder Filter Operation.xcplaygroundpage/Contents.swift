//: ## Moog Ladder Filter Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, _ in
    let frequency = AKOperation.sineWave(frequency: 1).scale(minimum: 500, maximum: 1_000)
    let resonance = abs(AKOperation.sineWave(frequency: 0.3)) * 0.95

    return player.moogLadderFilter(cutoffFrequency: frequency,
                                   resonance: resonance) * 3
}

AudioKit.output = effect
AudioKit.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
