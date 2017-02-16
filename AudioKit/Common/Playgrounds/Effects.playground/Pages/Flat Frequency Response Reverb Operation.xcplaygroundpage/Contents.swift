//: ## Flat Frequency Response Reverb Operation
//:

import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, _ in
    let duration = AKOperation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 5)

    return player.reverberateWithFlatFrequencyResponse(reverbDuration: duration,
                                                       loopDuration: 0.1)
}

AudioKit.output = effect
AudioKit.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
