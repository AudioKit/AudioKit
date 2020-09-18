//: ## Korg Low Pass Filter Operation
//:

import AudioKit

//: Noise Example
// Bring down the amplitude so that when it is mixed it is not so loud
let whiteNoise = WhiteNoise(amplitude: 0.1)
let filteredNoise = OperationEffect(whiteNoise) { whiteNoise in
    let cutoff = Operation.sineWave(frequency: 0.2).scale(minimum: 12_000, maximum: 100)
    return whiteNoise.korgLowPassFilter(cutoffFrequency: cutoff, resonance: 1, saturation: 1)
}

//: Music Example
let file = try AVAudioFile(readFileName: playgroundAudioFiles[0],
                           baseDir: .resources)

let player = try AudioPlayer(file: file)
player.looping = true
let filteredPlayer = OperationEffect(player) { player in
    let cutoff = Operation.sineWave(frequency: 0.2).scale(minimum: 12_000, maximum: 100)
    return player.korgLowPassFilter(cutoffFrequency: cutoff, resonance: 1, saturation: 1)
}

//: Mixdown and playback
let mixer = DryWetMixer(filteredNoise, filteredPlayer, balance: 0.5)
engine.output = mixer
try engine.start()

whiteNoise.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
