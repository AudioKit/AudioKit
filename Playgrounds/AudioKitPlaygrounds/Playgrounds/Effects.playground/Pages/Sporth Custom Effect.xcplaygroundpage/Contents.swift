//: ## Sporth Custom Effect
//: If you need to make a custom sporth function (also called a ugen),
//: you can pass instances of AKCustomUgen into AKOperationEffect's initializer,
//: and access these functions in your sporth code using the `f` function.
//:
//: In this example, we've created a function `throttle`, that limits the distance
//: that a float can move per second, which is useful for preventing a "pop"
//: when parameters are changed, or just as a linear version of `port`.
//:
//: Note that the function runs once for each sample, so you should make sure
//: any custom ugen functions you create run as quickly as possible, so the audio
//: stays smooth. This is why throttleUgen is defined in a separate file: if the
//: playground tries to log every iteration in the sidebar, it slows the function
//: down too much to work properly.
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)
var player = try AKAudioPlayer(file: file)
player.looping = true

let input  = AKStereoOperation.input.toMono()
let sporth = "(\(input) ((0 p) 40 (_throttle f)) 1000 100 pshift) dup"

let effect = AKOperationEffect(player, sporth: sporth, customUgens: [throttleUgen])

AudioKit.output = effect
AudioKit.start()

player.play()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

for i in 0..<100 {
  effect.parameters[0] = (i % 2 == 0) ? -12 : 12
  usleep(2_000_000)
}
