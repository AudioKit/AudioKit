//: ## Flat Frequency Response Reverb Operation
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let effect = OperationEffect(player) { player in
    let duration = Operation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 5)

    return player.reverberateWithFlatFrequencyResponse(reverbDuration: duration, loopDuration: 0.1)
}

engine.output = effect
try engine.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
