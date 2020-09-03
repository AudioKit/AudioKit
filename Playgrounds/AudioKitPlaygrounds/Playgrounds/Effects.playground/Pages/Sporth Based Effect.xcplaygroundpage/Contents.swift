//: ## Sporth Based Effect
//: AudioKit nodes can be creating using [Sporth](https://github.com/PaulBatchelor/Sporth).
//: This is an example of an effect written in Sporth.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let input = AKStereoOperation.input
let sporth = "\(input) 15 200 7.0 8.0 10000 315 0 1500 0 1 0 zitarev"

let effect = AKOperationEffect(player, sporth: sporth)

engine.output = effect
try engine.start()

player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
