//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AutoWah Operation
//: 
import PlaygroundSupport
import AudioKit

let bundle = Bundle.main()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

let wahAmount = AKOperation.sineWave(frequency: 0.6).scale(minimum: 1, maximum: 0)

let autowah = AKOperation.input.autoWah(wah: wahAmount, mix: 1, amplitude: 1)

let effect = AKOperationEffect(player, operation: autowah)

AudioKit.output = effect
AudioKit.start()
player.play()

PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
