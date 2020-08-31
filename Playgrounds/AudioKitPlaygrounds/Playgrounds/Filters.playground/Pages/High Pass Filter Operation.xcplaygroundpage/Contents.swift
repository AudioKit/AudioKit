//: ## High Pass Filter Operation
//:
import AudioKitPlaygrounds
import AudioKit

//: Noise Example
// Bring down the amplitude so that when it is mixed it is not so loud
let whiteNoise = AKWhiteNoise(amplitude: 0.1)
let filteredNoise = AKOperationEffect(whiteNoise) { whiteNoise in
    let halfPower = AKOperation.sineWave(frequency: 0.2).scale(minimum: 12_000, maximum: 100)
    return whiteNoise.highPassFilter(halfPowerPoint: halfPower)
}

//: Music Example
let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AKAudioPlayer(file: file)
player.looping = true
let filteredPlayer = AKOperationEffect(player) { player in
    let halfPower = AKOperation.sineWave(frequency: 0.2).scale(minimum: 12_000, maximum: 100)
    return player.highPassFilter(halfPowerPoint: halfPower)
}

//: Mixdown and playback
let mixer = AKDryWetMixer(filteredNoise, filteredPlayer, balance: 0.5)
engine.output = mixer
try engine.start()

whiteNoise.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
