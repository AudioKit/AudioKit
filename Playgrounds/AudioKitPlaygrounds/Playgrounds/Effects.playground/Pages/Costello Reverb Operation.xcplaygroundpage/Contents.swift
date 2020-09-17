//: ## Costello Reverb Operation
//:

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let effect = OperationEffect(player) { player in
    return player.reverberateWithCostello(
        feedback: Operation.sineWave(frequency: 0.1).scale(minimum: 0.5, maximum: 0.97),
        cutoffFrequency: 10_000)
}

engine.output = effect
try engine.start()
player.play()

//: User Interface

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Costello Reverb Operation")    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
