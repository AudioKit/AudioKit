//: ## Moog Ladder Filter Operation
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let effect = OperationEffect(player) { player in
    let frequency = Operation.sineWave(frequency: 1).scale(minimum: 500, maximum: 1_000)
    let resonance = abs(Operation.sineWave(frequency: 0.3)) * 0.95

    return player.moogLadderFilter(cutoffFrequency: frequency, resonance: resonance) * 3
}

engine.output = effect
try engine.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
