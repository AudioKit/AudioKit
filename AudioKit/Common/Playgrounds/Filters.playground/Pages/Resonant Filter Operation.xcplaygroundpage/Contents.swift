//: ## Resonant Filter Operation
//:
import PlaygroundSupport
import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, _ in
    let frequency = AKOperation.sineWave(frequency: 0.5).scale(minimum: 2_000, maximum: 5_000)
    let bandwidth = abs(AKOperation.sineWave(frequency: 0.3)) * 1_000

    return player.resonantFilter(frequency: frequency, bandwidth: bandwidth) * 0.1
}

AudioKit.output = effect
AudioKit.start()
player.play()

PlaygroundPage.current.needsIndefiniteExecution = true
