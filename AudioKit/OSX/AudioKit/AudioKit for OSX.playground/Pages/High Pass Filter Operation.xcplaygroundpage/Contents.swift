//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## High Pass Filter Operation
//:
import XCPlayground
import AudioKit

//: Filter setup
let halfPower = AKOperation.sineWave(frequency: 0.2).scale(minimum: 12000, maximum: 100)
let filter = AKOperation.input.highPassFilter(halfPowerPoint: halfPower)

//: Noise Example
let whiteNoise = AKWhiteNoise(amplitude: 0.1) // Bring down the amplitude so that when it is mixed it is not so loud
let filteredNoise = AKOperationEffect(whiteNoise, operation: filter)

//: Music Example
let file = try AKAudioFile(readFilename: "mixloop.wave", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
let filteredPlayer = AKOperationEffect(player, operation: filter)

//: Mixdown and playback
let mixer = AKDryWetMixer(filteredNoise, filteredPlayer, balance: 0.5)
AudioKit.output = mixer
AudioKit.start()

whiteNoise.start()
player.play()


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
