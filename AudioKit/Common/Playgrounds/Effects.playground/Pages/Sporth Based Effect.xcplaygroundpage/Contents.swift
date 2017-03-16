//: ## Sporth Based Effect
//: AudioKit nodes can be creating using [Sporth](https://github.com/PaulBatchelor/Sporth).
//: This is an example of an effect written in Sporth.

import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)
var player = try AKAudioPlayer(file: file)
player.looping = true

let input  = AKStereoOperation.input.toMono()
let sporth = "(\(input) ((0 p) 0.001 (_maxchange f)) 1000 100 pshift) dup"

let effect = AKOperationEffect(player, sporth: sporth, customUgens: [maxChangeUgen])

AudioKit.output = effect
AudioKit.start()

player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

for i in 0..<100 {
  effect.parameters[0] = (effect.parameters[0] == 12) ? -12 : 12
  usleep(2_000_000)
}
