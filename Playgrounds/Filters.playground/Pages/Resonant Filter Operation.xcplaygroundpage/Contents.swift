//: ## Resonant Filter Operation
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let effect = OperationEffect(player) { player in
    let frequency = Operation.sineWave(frequency: 0.5).scale(minimum: 2_000, maximum: 5_000)
    let bandwidth = abs(Operation.sineWave(frequency: 0.3)) * 1_000

    return player.resonantFilter(frequency: frequency, bandwidth: bandwidth) * 0.1
}

engine.output = effect
try engine.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
