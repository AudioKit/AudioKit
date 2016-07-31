//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Pass Filter Operation
//:
import XCPlayground
import AudioKit

//: Noise Example
// Bring down the amplitude so that when it is mixed it is not so loud
let whiteNoise = AKWhiteNoise(amplitude: 0.1)
let filteredNoise = AKOperationEffect(whiteNoise) { whiteNoise, _ in
    let halfPower = AKOperation.sineWave(frequency: 0.2).scale(minimum: 12000, maximum: 100)
    return whiteNoise.lowPassFilter(halfPowerPoint: halfPower)
}

//: Music Example
let file = try AKAudioFile(readFileName: audioResourceFileNames[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
let filteredPlayer = AKOperationEffect(player) { player, _ in
    let halfPower = AKOperation.sineWave(frequency: 0.2).scale(minimum: 12000, maximum: 100)
    return player.lowPassFilter(halfPowerPoint: halfPower)
}

//: Mixdown and playback
let mixer = AKDryWetMixer(filteredNoise, filteredPlayer, balance: 0.5)
AudioKit.output = mixer
AudioKit.start()

whiteNoise.start()
player.play()


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
