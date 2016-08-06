//: ## Smooth Delay Operation
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[7],
                           baseDir: .Resources)

var player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, _ in
    let time = AKOperation.sineWave(frequency: 0.3).scale(minimum: 0.01, maximum: 0.2)
    let feedback = AKOperation.sineWave(frequency: 0.21).scale(minimum: 0.5, maximum: 0.95)
    let delayedPlayer = player.smoothDelay(
        time: time,
        samples: 1024,
        feedback: feedback,
        maximumDelayTime: 2.0)
    return mixer(player.toMono(), delayedPlayer)
}

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
