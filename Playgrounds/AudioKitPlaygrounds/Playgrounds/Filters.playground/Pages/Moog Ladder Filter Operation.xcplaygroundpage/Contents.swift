//: ## Moog Ladder Filter Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player in
    let frequency = AKOperation.sineWave(frequency: 1).scale(minimum: 500, maximum: 1_000)
    let resonance = abs(AKOperation.sineWave(frequency: 0.3)) * 0.95

    return player.moogLadderFilter(cutoffFrequency: frequency, resonance: resonance) * 3
}

engine.output = effect
try engine.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
