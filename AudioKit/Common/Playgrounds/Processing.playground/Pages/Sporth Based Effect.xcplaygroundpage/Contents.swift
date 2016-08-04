//: ## Sporth Based Effect
//: ### You can create nodes for AudioKit using [Sporth](https://github.com/PaulBatchelor/Sporth).
//: ### This is an example of an effect written in Sporth.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)
var player = try AKAudioPlayer(file: file)
player.looping = true

let input  = AKStereoOperation.input
let sporth = "\(input) 15 200 7.0 8.0 10000 315 0 1500 0 1 0 zitarev"

let effect = AKOperationEffect(player, sporth: sporth)

AudioKit.output = effect
AudioKit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
