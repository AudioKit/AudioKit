//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Flat Frequency Response Reverb Operation
//:
import XCPlayground
import AudioKit

//: Music Example
let file = try AKAudioFile(forReadingFileName: "drumloop", withExtension: "wav", fromBaseDirectory: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let duration = AKOperation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 5)

let reverb = AKOperation.input.reverberateWithFlatFrequencyResponse(reverbDuration: duration, loopDuration: 0.1)
let effect = AKOperationEffect(player, operation: reverb)

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
