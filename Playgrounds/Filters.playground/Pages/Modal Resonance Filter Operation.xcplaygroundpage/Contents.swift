//: ## Modal Resonance Filter Operation
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let frequency = Operation.sineWave(frequency: 0.3).scale(minimum: 200, maximum: 1_200)

let effect = OperationEffect(player) { player in
    return player.modalResonanceFilter(frequency: frequency, qualityFactor: 50) * 0.2
}

engine.output = effect
try engine.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
