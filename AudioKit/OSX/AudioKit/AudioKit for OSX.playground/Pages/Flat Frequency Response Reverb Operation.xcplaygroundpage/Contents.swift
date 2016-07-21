//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Flat Frequency Response Reverb Operation
//:
import XCPlayground
import AudioKit

//: Music Example
let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)


//: Here we set up a player to the loop the file's playback
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

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
