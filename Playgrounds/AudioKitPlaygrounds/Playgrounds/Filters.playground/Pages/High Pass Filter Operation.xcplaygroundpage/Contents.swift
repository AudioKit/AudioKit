//: ## High Pass Filter Operation
//:

import AudioKit

//: Noise Example
// Bring down the amplitude so that when it is mixed it is not so loud
let whiteNoise = WhiteNoise(amplitude: 0.1)
let filteredNoise = OperationEffect(whiteNoise) { whiteNoise in
    let halfPower = Operation.sineWave(frequency: 0.2).scale(minimum: 12_000, maximum: 100)
    return whiteNoise.highPassFilter(halfPowerPoint: halfPower)
}

//: Music Example
let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AudioPlayer(file: file)
player.looping = true
let filteredPlayer = OperationEffect(player) { player in
    let halfPower = Operation.sineWave(frequency: 0.2).scale(minimum: 12_000, maximum: 100)
    return player.highPassFilter(halfPowerPoint: halfPower)
}

//: Mixdown and playback
let mixer = DryWetMixer(filteredNoise, filteredPlayer, balance: 0.5)
engine.output = mixer
try engine.start()

whiteNoise.start()
player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
