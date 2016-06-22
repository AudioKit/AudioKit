//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Flat Frequency Response Reverb Operation
//:
import XCPlayground
import AudioKit

//: Music Example
let file = try AKAudioFile(forReadingWithFileName: "drumloop", andExtension: "wav", fromBaseDirectory: .Resources)


//: Here we set up a player to the loop the file's playback
let player = try AKAudioPlayer(file: file)
player.looping = true

//: The amplitude tracker's passes its input to the output, so we can insert into the signal chain at the bottom
let duration = AKOperation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 5)

let reverb = AKOperation.input.reverberateWithFlatFrequencyResponse(reverbDuration: duration, loopDuration: 0.1)
let effect = AKOperationEffect(player, operation: reverb)

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
