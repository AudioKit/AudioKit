//: ## Low Pass Filter Operation
//:
import PlaygroundSupport
import AudioKit

//: Noise Example
// Bring down the amplitude so that when it is mixed it is not so loud
let whiteNoise = AKWhiteNoise(amplitude: 0.1)
let filteredNoise = AKOperationEffect(whiteNoise) { whiteNoise, _ in
    let cutoff = AKOperation.sineWave(frequency: 0.2).scale(minimum: 12000, maximum: 100)
    return whiteNoise.korgLowPassFilter(cutoffFrequency: cutoff, resonance: 1, saturation: 1)
}

//: Music Example
let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
let filteredPlayer = AKOperationEffect(player) { player, _ in
    let cutoff = AKOperation.sineWave(frequency: 0.2).scale(minimum: 12000, maximum: 100)
    return player.korgLowPassFilter(cutoffFrequency: cutoff, resonance: 1, saturation: 1)
}

//: Mixdown and playback
let mixer = AKDryWetMixer(filteredNoise, filteredPlayer, balance: 0.5)
AudioKit.output = mixer
AudioKit.start()

whiteNoise.start()
player.play()


PlaygroundPage.current.needsIndefiniteExecution = true
