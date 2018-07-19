//: ## Sporth Based Effect
//: AudioKit nodes can be creating using [Sporth](https://github.com/PaulBatchelor/Sporth).
//: This is an example of an effect written in Sporth.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
var player = AKPlayer(audioFile: file)
player.isLooping = true

let input = AKStereoOperation.input
let sporth = "\(input) 15 200 7.0 8.0 10000 315 0 1500 0 1 0 zitarev"

let effect = AKOperationEffect(player, sporth: sporth)

AudioKit.output = effect
try AudioKit.start()

player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
